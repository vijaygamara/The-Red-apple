import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:the_red_apple/Teacher_Login_Screen/teacherlogin.dart';
import 'package:the_red_apple/utils/AppColors.dart';

import '../student_dashborad_screen/student_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initMessaging();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentLogin()),
      );
    });
  }

  void _initMessaging() {
    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        showSimpleNotification(
          Text(notification.title ?? 'Notification'),
          subtitle: Text(notification.body ?? ''),
          background: Colors.blue,
          autoDismiss: true,
          slideDismissDirection: DismissDirection.up,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.1),
            Container(
              height: size.height * 0.4,
              width: size.width * 0.7,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Assets/images/red_apple.jpg'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading.....',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
