import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:the_red_apple/Splash_screen/Splash_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/student_dashborad.dart';
import 'student_dashborad_screen/student_login.dart';
import 'utils/firebase_config.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background isolate
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _initFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: const SplashScreen(),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}






// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const UploadImagePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class UploadImagePage extends StatefulWidget {
//   const UploadImagePage({super.key});
//
//   @override
//   State<UploadImagePage> createState() => _UploadImagePageState();
// }
//
// class _UploadImagePageState extends State<UploadImagePage> {
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//   bool _uploading = false;
//   String? _downloadUrl;
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _uploadImage() async {
//     if (_imageFile == null) return;
//     setState(() => _uploading = true);
//
//     try {
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       final storageRef = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
//       await storageRef.putFile(_imageFile!);
//       final url = await storageRef.getDownloadURL();
//
//       setState(() {
//         _downloadUrl = url;
//         _uploading = false;
//       });
//     } catch (e) {
//       setState(() => _uploading = false);
//       print('Upload error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Image to Firebase")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _imageFile != null
//                 ? Image.file(_imageFile!, height: 200)
//                 : const Placeholder(fallbackHeight: 200),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.photo_library),
//               label: const Text("Pick Image"),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: _uploading ? null : _uploadImage,
//               icon: const Icon(Icons.cloud_upload),
//               label: Text(_uploading ? "Uploading..." : "Upload to Firebase"),
//             ),
//             const SizedBox(height: 20),
//             if (_downloadUrl != null)
//               SelectableText("Download URL:\n$_downloadUrl"),
//           ],
//         ),
//       ),
//     );
//   }
// }
