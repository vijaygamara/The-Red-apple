import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_red_apple/Teacher_Login_Screen/teacherlogin.dart';
import 'package:the_red_apple/student_dashborad_screen/student_dashborad.dart';
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
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        // already logged in → go to StudentDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboard(studentData: {
              "Student Id": user.uid,
              // agar extra data chahiye to Firestore se fetch kar sakte ho
            }),
          ),
        );
      } else {
        // not logged in → go to Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentLogin()),
        );
      }
    }
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
