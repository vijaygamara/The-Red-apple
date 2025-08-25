import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/notification_service.dart';

class NoteScreen extends StatefulWidget {
  final Map<String, dynamic>? noteData;
  final String? docId;

  const NoteScreen({super.key, this.noteData, this.docId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedMedium;
  String? _selectedClass;
  DateTime? _selectedDate;
  bool _isSaving = false;
  bool _sendNotification = true;

  List<String> mediumList = ['English Medium', 'Gujarati Medium'];
  List<String> classList = [];
  bool isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    if (widget.noteData != null) {
      final data = widget.noteData!;
      _selectedMedium = data['medium'];
      _selectedClass = data['class'];
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _selectedDate = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
      if (_selectedMedium != null) fetchClassesByMedium(_selectedMedium!);
    }
  }

  Future<void> fetchClassesByMedium(String medium) async {
    setState(() {
      isLoadingClasses = true;
      _selectedClass = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('medium', isEqualTo: medium)
          .get();

      final classes = snapshot.docs.map((doc) {
        return doc.data()['className'] as String;
      }).toList();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
    } catch (e) {
      setState(() => isLoadingClasses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveNote() async {
    if (_selectedMedium == null || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Medium and Class')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and content')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'medium': _selectedMedium,
        'class': _selectedClass,
        'date': dateStr,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef;
      if (widget.docId != null) {
        docRef = FirebaseFirestore.instance.collection('notes').doc(widget.docId);
        await docRef.update(data);
      } else {
        docRef = await FirebaseFirestore.instance.collection('notes').add(data);
      }

      // 🔔 Send notification
      if (_sendNotification) {
        await NotificationService.sendNoteNotification(
          className: _selectedClass!,
          medium: _selectedMedium!,
          noteTitle: _titleController.text.trim(),
          noteContent: _contentController.text.trim(),
        );

        await NotificationService.saveNotificationToFirestore(
          type: 'note',
          className: _selectedClass!,
          medium: _selectedMedium!,
          title: 'New Note: ${_titleController.text.trim()}',
          body: _contentController.text.trim(),
          data: {
            'noteId': docRef.id,
            'date': dateStr,
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId != null ? 'Note updated successfully!' : 'Note saved and sent!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          widget.docId != null ? 'Edit Note' : 'Write Note',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Medium
          const Text('Medium', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _selectedMedium,
            items: mediumList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (value) async {
              setState(() => _selectedMedium = value);
              if (value != null) await fetchClassesByMedium(value);
            },
          ),
          const SizedBox(height: 16),

          // Class
          const Text('Class', style: TextStyle(fontWeight: FontWeight.bold)),
          isLoadingClasses
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
            value: _selectedClass,
            items: classList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (value) => setState(() => _selectedClass = value),
          ),
          const SizedBox(height: 16),

          // Date
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Date"),
              child: Text(DateFormat('dd MMM yyyy').format(_selectedDate!)),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Note Title", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),

          // Content
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: const InputDecoration(labelText: "Note Content", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),

          if (widget.docId == null)
            Row(
              children: [
                Checkbox(
                  value: _sendNotification,
                  onChanged: (v) => setState(() => _sendNotification = v ?? true),
                ),
                const Text("Send notification"),
              ],
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveNote,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4D8)),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.docId != null ? "Update Note" : "Save Note"),
            ),
          )
        ]),
      ),
    );
  }
}
