import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_red_apple/SignupPage/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70,),
            Container(
              height: 350,
              width: 350,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('Assets/images/red_apple.jpg'))),
            ),
            SizedBox(
              height: 0,
            ),
            Text(
              'The Red Apple Pre - School',
              style: GoogleFonts.almendra(
                  fontSize: 22, fontWeight: FontWeight.bold,
              color: Colors.red
              ),
            ),
            SizedBox(
              height: 300,
            ),
            SizedBox(height: 10,),
            Text(
              'Loading.....',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
