import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../student_dashborad_screen/student_login.dart';

void _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('phone');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const StudentLogin()),
  );
}
