import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({super.key});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile>? selectedImages = await _picker.pickMultiImage();
      if (selectedImages != null && selectedImages.isNotEmpty) {
        setState(() {
          _images = selectedImages;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<List<String>> _uploadImages(String docId) async {
    try {
      List<String> urls = [];
      for (int i = 0; i < _images.length; i++) {
        final imageFile = File(_images[i].path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('event_images/$docId/image_$i.jpg');

        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      debugPrint("Image upload error: $e");
      return [];
    }
  }

  Future<void> _saveEvent() async {
    final desc = _descController.text.trim();

    if (desc.isEmpty || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter description and select images')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final docRef = await FirebaseFirestore.instance.collection('events').add({
        'description': desc,
        'createdAt': FieldValue.serverTimestamp(),
        'images': [],
      });

      final urls = await _uploadImages(docRef.id);

      await docRef.update({'images': urls});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved successfully'), backgroundColor: Colors.green),
      );

      setState(() {
        _descController.clear();
        _images = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event'), backgroundColor: Colors.red),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: 'Enter event description...',
                prefixIcon: const Icon(Icons.event_note, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              maxLines: 5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Select Images"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _images.isEmpty
                ? const Center(child: Text('No images selected'))
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) => Image.file(
                File(_images[index].path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _saveEvent,
        backgroundColor: Colors.red,
        icon: _isUploading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.save),
        label: Text(_isUploading ? 'Saving...' : 'Save'),
      ),
    );
  }
}
