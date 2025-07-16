import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUtils {
  /// Compress image to reduce file size while maintaining quality
  static Future<File> compressImage(File file) async {
    try {
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 85, // Good quality with reasonable file size
        minWidth: 1024, // Max width
        minHeight: 1024, // Max height
      );
      
      if (compressedBytes != null) {
        // Create temporary file for compressed image
        final String tempPath = '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File compressedFile = File(tempPath);
        await compressedFile.writeAsBytes(compressedBytes);
        return compressedFile;
      }
      
      return file; // Return original if compression fails
    } catch (e) {
      print('Image compression failed: $e');
      return file; // Return original if compression fails
    }
  }

  /// Upload image to Firebase Storage
  static Future<String> uploadImageToFirebase(File imageFile, String folderPath, String fileName) async {
    try {
      // Compress the image first
      final File compressedFile = await compressImage(imageFile);
      
      // Create reference to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('$folderPath/$fileName');

      // Upload the compressed image
      final UploadTask uploadTask = storageRef.putFile(compressedFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();
      
      // Clean up compressed file
      await compressedFile.delete();
      
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload multiple images to Firebase Storage
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles, String folderPath) async {
    List<String> downloadURLs = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final String downloadURL = await uploadImageToFirebase(imageFiles[i], folderPath, fileName);
        downloadURLs.add(downloadURL);
      } catch (e) {
        print('Error uploading image $i: $e');
        rethrow;
      }
    }

    return downloadURLs;
  }

  /// Delete image from Firebase Storage
  static Future<void> deleteImageFromFirebase(String imageUrl) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }
} 