import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  final Map<String, dynamic>? noteData;
  final String? docId;

  const NoteScreen({super.key, this.noteData, this.docId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // State
  String? _selectedMedium;
  String? _selectedClass;
  DateTime? _selectedDate;
  bool _isSaving = false;
  bool _sendNotification = true;

  // Data
  List<String> mediumList = ['English Medium', 'Gujarati Medium'];
  List<String> classList = [];
  bool isLoadingClasses = false;

  // Design tokens to match screenshot
  final Color kPrimary = const Color(0xFF00B4D8); // AppBar cyan
  final Color kStroke = const Color(0xFF7E57C2); // purple outline
  final Color kCheckbox = const Color(0xFF6F47C7); // checkbox active
  final double kRadius = 12; // corners
  final double kGap = 16; // spacing

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
      _sendNotification = (data['sendNotification'] ?? true) as bool;
      if (_selectedMedium != null) fetchClassesByMedium(_selectedMedium!);
    }
  }

  // Common decoration for identical field look
  InputDecoration _uiDeco({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      hintStyle: GoogleFonts.poppins(color: Colors.black38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadius),
        borderSide: BorderSide(color: kStroke, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadius),
        borderSide: BorderSide(color: kStroke, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadius),
        borderSide: BorderSide(color: kStroke, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> fetchClassesByMedium(String medium) async {
    setState(() {
      isLoadingClasses = true;
      _selectedClass = null;
      classList = [];
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('medium', isEqualTo: medium)
          .get();

      final classes = snapshot.docs
          .map((doc) => (doc.data()['className'] as String?)?.trim())
          .whereType<String>()
          .toList()
        ..sort();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
    } catch (e) {
      setState(() => isLoadingClasses = false);
      if (!mounted) return;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
            Theme.of(context).colorScheme.copyWith(primary: kPrimary),
          ),
          child: child!,
        );
      },
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

    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
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
        'sendNotification': _sendNotification,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        // Update
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.docId)
            .update(data);
      } else {
        // Add new
        await FirebaseFirestore.instance.collection('notes').add(data);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.docId != null
              ? 'Note updated successfully!'
              : 'Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar matches screenshot
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          widget.docId != null ? 'Edit Note' : 'Write Note',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),

      // Make AppBar title look like screenshot via theme override
      extendBodyBehindAppBar: false,
      // AppBar text style
      // (Alternative: set in ThemeData app-wide)
      // For brevity, we keep default and rely on color

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Medium
          _sectionLabel('Medium'),
          DropdownButtonFormField<String>(
            value: _selectedMedium,
            items: mediumList
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (value) async {
              setState(() => _selectedMedium = value);
              if (value != null) await fetchClassesByMedium(value);
            },
            decoration: _uiDeco(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(14),
          ),
          SizedBox(height: kGap),

          // Class
          _sectionLabel('Class'),
          isLoadingClasses
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Center(child: CircularProgressIndicator()),
          )
              : DropdownButtonFormField<String>(
            value: _selectedClass,
            items: classList
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => _selectedClass = value),
            decoration: _uiDeco(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(14),
          ),
          SizedBox(height: kGap),

          // Date
          _sectionLabel('Date'),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(kRadius),
            child: InputDecorator(
              decoration: _uiDeco(),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 20, color: Colors.black54),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate!),
                    style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: kGap),

          // Title
          _sectionLabel('Note Title'),
          TextField(
            controller: _titleController,
            decoration: _uiDeco(hint: 'Enter note title'),
          ),
          SizedBox(height: kGap),

          // Content
          _sectionLabel('Note Content'),
          TextField(
            controller: _contentController,
            maxLines: 8,
            decoration: _uiDeco(hint: 'Write your note here...').copyWith(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            ),
          ),
          const SizedBox(height: 24),

          // Checkbox row
          Row(
            children: [
              Checkbox(
                value: _sendNotification,
                onChanged: (v) =>
                    setState(() => _sendNotification = v ?? true),
                activeColor: kCheckbox,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Send notification to students',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Save/Update button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadius),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                widget.docId != null ? "Update Note" : "Save Note",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
