import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_red_apple/Teacher_Login_Screen/teacherlogin.dart';
import 'package:the_red_apple/student_dashborad_screen/student_login.dart';
import 'package:the_red_apple/student_dashborad_screen/student_dashborad.dart';
import 'package:the_red_apple/utils/AppColors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn != null && isLoggedIn) {
      String? phone = prefs.getString('phone');
      if (phone != null) {
        final query = await FirebaseFirestore.instance
            .collection('students')
            .where('Mobile Number', isEqualTo: phone)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final studentData = query.docs.first.data();
          if (studentData != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDashboard(studentData: studentData),
              ),
            );
            return;
          }
        }
      }
    }

    // Not logged in → show student login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TeacherLogin()),
    );
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
