// Updated ResultScreen with Edit Capability
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;

  const ResultScreen({super.key, this.existingData, this.docId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _selectedClass;
  String? selectedMedium;
  List<String> mediumList = ['English Medium', 'Gujarati Medium'];
  List<String> classList = [];

  bool isLoadingClasses = false;
  bool isUploading = false;

  final List<XFile> _images = [];
  List<String> existingImageUrls = [];
  final TextEditingController _noteController = TextEditingController();

  Future<void> fetchClassesByMedium(String medium) async {
    setState(() {
      isLoadingClasses = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('medium', isEqualTo: medium)
          .get();

      final classes = querySnapshot.docs
          .map((doc) => doc.data()['className'] as String)
          .toList();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      setState(() => isLoadingClasses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final selectedImages = await picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages);
      });
    }
  }

  Future<List<String>> _uploadImagesToStorage() async {
    List<String> imageUrls = List.from(existingImageUrls);
    for (var image in _images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('result_images/$fileName.jpg');
      await ref.putFile(File(image.path));
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  void _uploadResult() async {
    if (selectedMedium == null || selectedMedium!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medium.')),
      );
      return;
    }

    if (_selectedClass == null || _selectedClass!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class.')),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      List<String> imageUrls = await _uploadImagesToStorage();

      final data = {
        'Class': _selectedClass,
        'Medium': selectedMedium,
        'Text': _noteController.text.trim(),
        'Images': imageUrls,
        'Timestamp': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('results')
            .doc(widget.docId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('results').add(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result saved successfully!')),
      );

      setState(() {
        _noteController.clear();
        _selectedClass = null;
        selectedMedium = null;
        _images.clear();
        existingImageUrls.clear();
        classList.clear();
        isUploading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving result: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _selectedClass = data['Class'];
      selectedMedium = data['Medium'];
      _noteController.text = data['Text'] ?? '';
      existingImageUrls = List<String>.from(data['Images'] ?? []);
      fetchClassesByMedium(selectedMedium ?? '');
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.docId != null ? 'Edit Result' : 'Student Results',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Medium", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMedium,
                      isExpanded: true,
                      hint: Text("Select Medium", style: GoogleFonts.alatsi(fontSize: 16)),
                      items: mediumList.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: GoogleFonts.alatsi(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMedium = value;
                          _selectedClass = null;
                          classList = [];
                          fetchClassesByMedium(value!);
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text('Class', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              isLoadingClasses
                  ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
                  : Card(
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
                    items: classList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedClass = v),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text('Note & Comment', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter any remarks or note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text("Select Results Images",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 25),
              if (existingImageUrls.isNotEmpty || _images.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      ...existingImageUrls.map((url) => Image.network(url, fit: BoxFit.cover)),
                      ..._images.map((xfile) => Image.file(File(xfile.path), fit: BoxFit.cover)),
                    ],
                  ),
                ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: isUploading ? null : _uploadResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.docId != null ? "Update Result" : "Upload Result",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}