import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_red_apple/student_dashborad_screen/attendance_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/class_record_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/event_photos_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/homework_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/result_screen.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData; // 🔥 Add this line

  const StudentDashboard({super.key, required this.studentData});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AttendanceScreen(),
    HomeworkScreen(),
    ResultScreen(),
    EventPhotosScreen(),
    ClassRecordScreen(),
  ];

  final List<String> _titles = [
    "Attendance",
    "Homework",
    "Result",
    "Event Photos",
    "Class Record",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Homework',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Result',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Class',
          ),
        ],
      ),
    );
  }
}
