import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/image_utils.dart';

class Homework extends StatefulWidget {
  final Map<String, dynamic>? homeworkData;
  final String? docId;

  const Homework({super.key, this.homeworkData, this.docId});

  @override
  State<Homework> createState() => _HomeworkState();
}

class _HomeworkState extends State<Homework> {
  final TextEditingController _textController = TextEditingController();
  final List<XFile> _images = [];
  String? _selectedClass;
  DateTime? _selectedDate;
  bool _isUploading = false;

  List<String> classList = [];
  bool isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    fetchClasses();

    if (widget.homeworkData != null) {
      final data = widget.homeworkData!;
      _selectedClass = data['class'];
      _textController.text = data['text'] ?? '';
      _selectedDate = DateTime.tryParse(data['date'] ?? '');
    }
  }

  Future<void> fetchClasses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('classes').get();

      // debug print for testing fetched classes
      debugPrint("Classes docs fetched: ${querySnapshot.docs.length}");

      final classes = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['className'] as String?)
          .where((className) => className != null && className.isNotEmpty)
          .cast<String>()
          .toList();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      setState(() {
        isLoadingClasses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final selectedImages = await picker.pickMultiImage();
    if (selectedImages !=null && selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images, String docId) async {
    try {
      List<File> imageFiles = images.map((xFile) => File(xFile.path)).toList();
      return await ImageUtils.uploadMultipleImages(imageFiles, 'homework_images/$docId');
    } catch (e) {
      debugPrint('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload images: $e')),
      );
      return [];
    }
  }

  Future<void> _uploadHomework() async {
    if (_selectedClass == null || _selectedDate == null || (_images.isEmpty && _textController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide class, date and homework.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final data = {
        'class': _selectedClass,
        'date': _selectedDate!.toIso8601String(),
        'text': _textController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'images': [],
      };

      DocumentReference docRef;
      if (widget.docId != null) {
        docRef = FirebaseFirestore.instance.collection('homework').doc(widget.docId);
        await docRef.update(data);
      } else {
        docRef = await FirebaseFirestore.instance.collection('homework').add(data);
      }

      if (_images.isNotEmpty) {
        final imageUrls = await _uploadImages(_images, docRef.id);
        await docRef.update({'images': imageUrls});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId != null ? "Homework updated successfully!" : "Homework uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading homework: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.red.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId != null ? 'Edit Homework' : 'Upload Homework',style: TextStyle(
          fontSize: 25,fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.red,
      ),
      body: isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedClass,
                  items: classList
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                onTap: _pickDate,
                leading: const Icon(Icons.calendar_today, color: Colors.red),
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.edit_calendar),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                onTap: _pickImages,
                leading: const Icon(Icons.image, color: Colors.red),
                title: const Text("Select Images"),
                trailing: const Icon(Icons.add_photo_alternate),
              ),
            ),
            const SizedBox(height: 10),
            _images.isNotEmpty
                ? SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_images[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(index)),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
                : const Text("No image selected", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Write homework text here...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadHomework,
              icon: _isUploading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.upload_outlined),
              label: Text(_isUploading
                  ? "Uploading..."
                  : (widget.docId != null ? "Update Homework" : "Upload Homework")),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}
