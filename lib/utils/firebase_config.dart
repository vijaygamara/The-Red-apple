import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  /// Initialize Firebase Storage with proper configuration
  static void initializeStorage() {
    // Set cache size for better performance
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 30));
    FirebaseStorage.instance.setMaxDownloadRetryTime(const Duration(seconds: 30));
  }

  /// Get Firestore instance with proper settings
  static FirebaseFirestore getFirestore() {
    return FirebaseFirestore.instance;
  }

  /// Get Storage instance
  static FirebaseStorage getStorage() {
    return FirebaseStorage.instance;
  }

  /// Check if Firebase is properly initialized
  static bool isInitialized() {
    try {
      // Try to access Firebase Storage to check if it's initialized
      FirebaseStorage.instance;
      return true;
    } catch (e) {
      print('Firebase not initialized: $e');
      return false;
    }
  }
} 