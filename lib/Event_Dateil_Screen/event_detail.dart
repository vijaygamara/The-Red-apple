import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({super.key});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  XFile? _selectedVideo;
  VideoPlayerController? _videoController;
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

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(File(video.path));
        await _videoController!.initialize();
        setState(() {
          _selectedVideo = video;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
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

  Future<String?> _uploadVideo(String docId) async {
    if (_selectedVideo == null) return null;
    try {
      final file = File(_selectedVideo!.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('event_videos/$docId/video.mp4');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Video upload error: $e");
      return null;
    }
  }

  Future<void> _saveEvent() async {
    final desc = _descController.text.trim();

    if (desc.isEmpty || (_images.isEmpty && _selectedVideo == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter description and select image or video')),
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
        'video': '',
      });

      final urls = await _uploadImages(docRef.id);
      final videoUrl = await _uploadVideo(docRef.id);

      await docRef.update({
        'images': urls,
        'video': videoUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved successfully'), backgroundColor: Colors.green),
      );

      setState(() {
        _descController.clear();
        _images = [];
        _selectedVideo = null;
        _videoController?.dispose();
        _videoController = null;
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
  void dispose() {
    _descController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'Add Event',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
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
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text("Select Images"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text("Select Video"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _images.isEmpty
                      ? const Text('No images selected')
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                  const SizedBox(height: 10),
                  _selectedVideo != null && _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                      : const Text('No video selected'),
                ],
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
