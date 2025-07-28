import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:the_red_apple/Splash_screen/Splash_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/student_dashborad.dart';
import 'package:the_red_apple/user_screen/user_screen.dart';
import 'student_dashborad_screen/student_login.dart';
import 'utils/firebase_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  runApp(const MyApp());
}

Future<void> _initFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const SplashScreen(),
      home:  StudentLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
