import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_red_apple/Result_Screen/result_screen.dart';

import '../Attendance_Screen/attendancescreen.dart';

class AttendanceView extends StatelessWidget {

  const AttendanceView({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance View",style: TextStyle(
            fontSize: 25,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AttendanceScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
