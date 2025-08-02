import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:the_red_apple/student_dashborad_screen/attendance_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/homework_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/result_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/event_photos_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboard({super.key, required this.studentData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  int get maxCount => 5;

  @override
  void initState() {
    super.initState();
    _controller.index = 0;

    _controller.addListener(() {
      _pageController.jumpToPage(_controller.index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late final List<Widget> _screens = [
    AttendanceScreen(studentData: widget.studentData),
    HomeworkScreen(studentData: widget.studentData),
    ResultScreen(studentData: widget.studentData),
    const EventPhotosScreen(),
    ProfileScreen(studentData: widget.studentData),
  ];

  final List<IconData> _icons = [
    Icons.check_circle_outline,
    Icons.book,
    Icons.grade,
    Icons.photo_library,
    Icons.person,
  ];

  final List<String> _labels = [
    "Attendance",
    "Homework",
    "Result",
    "Events",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: (_screens.length <= maxCount)
          ? AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Colors.blueAccent,
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 10,
        kIconSize: 24.0,
        bottomBarItems: List.generate(_screens.length, (index) {
          return BottomBarItem(
            inActiveItem: Icon(_icons[index], color: Colors.grey[600]),
            activeItem: Icon(_icons[index], color: Colors.white),
            itemLabel: _labels[index],
          );
        }),
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      )
          : null,
    );
  }
}
