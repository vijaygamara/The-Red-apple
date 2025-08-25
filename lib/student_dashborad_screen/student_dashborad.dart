// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
// import 'package:the_red_apple/student_dashborad_screen/student_attendance_screen.dart';
// import 'package:the_red_apple/student_dashborad_screen/homework_screen.dart';
// import 'package:the_red_apple/student_dashborad_screen/result_screen.dart';
// import 'package:the_red_apple/student_dashborad_screen/event_photos_screen.dart';
// import 'package:the_red_apple/student_dashborad_screen/profile_screen.dart';
//
// class StudentDashboard extends StatefulWidget {
//   final Map<String, dynamic> studentData;
//
//   const StudentDashboard({super.key, required this.studentData});
//
//   @override
//   State<StudentDashboard> createState() => _StudentDashboardState();
// }
//
// class _StudentDashboardState extends State<StudentDashboard> {
//   /// Controller to handle PageView and also handles initial page
//   final _pageController = PageController(initialPage: 0);
//
//   /// Controller to handle bottom nav bar and also handles initial page
//   final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
//
//   int get maxCount => 5;
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   List<Widget> get _screens => [
//     StudentAttendanceScreen(
//       studentId: '', // We'll get this from the document ID
//       studentName: widget.studentData['Student Name'] ?? '',
//       className: widget.studentData['Class Name'] ?? '',
//       medium: widget.studentData['Medium'] ?? '',
//       mobileNumber: widget.studentData['Mobile Number'] ?? '',
//     ),
//     HomeworkScreen(studentData: widget.studentData),
//     ResultScreen(studentData: widget.studentData),
//     EventPhotosScreen(),
//     ProfileScreen(studentData: widget.studentData),
//   ];
//
//   /// Your existing icons
//   final List<IconData> _icons = [
//     Icons.check_circle_outline,
//     Icons.book,
//     Icons.grade,
//     Icons.photo_library,
//     Icons.person,
//   ];
//
//   /// Your existing labels
//   final List<String> _labels = [
//     "Attendance",
//     "Homework",
//     "Result",
//     "Events",
//     "Profile",
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: List.generate(_screens.length, (index) => _screens[index]),
//       ),
//       extendBody: true,
//       bottomNavigationBar: (_screens.length <= maxCount)
//           ? AnimatedNotchBottomBar(
//         /// Provide NotchBottomBarController
//         notchBottomBarController: _controller,
//         color: Colors.white,
//         showLabel: true,
//         textOverflow: TextOverflow.visible,
//         maxLine: 1,
//         shadowElevation: 5,
//         kBottomRadius: 28.0,
//
//         /// Changed to accentBlue for the notch
//         notchColor: Colors.blueAccent,
//
//         /// Remove margins for full-width effect
//         removeMargins: false,
//         bottomBarWidth: 500,
//         showShadow: true,
//         durationInMilliSeconds: 300,
//
//         /// Custom label style with your Google Fonts
//         itemLabelStyle: GoogleFonts.poppins(
//           fontSize: 11,
//           fontWeight: FontWeight.w400,
//         ),
//
//         elevation: 10,
//
//         /// Your custom bottom bar items using your existing icons and labels
//         bottomBarItems: [
//           BottomBarItem(
//             inActiveItem: Icon(
//               _icons[0],
//               color: Colors.grey[600],
//             ),
//             activeItem: Icon(
//               _icons[0],
//               color: Colors.white,
//             ),
//             itemLabel: _labels[0],
//           ),
//           BottomBarItem(
//             inActiveItem: Icon(
//               _icons[1],
//               color: Colors.grey[600],
//             ),
//             activeItem: Icon(
//               _icons[1],
//               color: Colors.white,
//             ),
//             itemLabel: _labels[1],
//           ),
//           BottomBarItem(
//             inActiveItem: Icon(
//               _icons[2],
//               color: Colors.grey[600],
//             ),
//             activeItem: Icon(
//               _icons[2],
//               color: Colors.white,
//             ),
//             itemLabel: _labels[2],
//           ),
//           BottomBarItem(
//             inActiveItem: Icon(
//               _icons[3],
//               color: Colors.grey[600],
//             ),
//             activeItem: Icon(
//               _icons[3],
//               color: Colors.white,
//             ),
//             itemLabel: _labels[3],
//           ),
//           BottomBarItem(
//             inActiveItem: Icon(
//               _icons[4],
//               color: Colors.grey[600],
//             ),
//             activeItem: Icon(
//               _icons[4],
//               color: Colors.white,
//             ),
//             itemLabel: _labels[4],
//           ),
//         ],
//         onTap: (index) {
//           /// Handle page navigation
//           _pageController.jumpToPage(index);
//         },
//         kIconSize: 24.0,
//       )
//           : null,
//     );
//   }
// }


import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_red_apple/student_dashborad_screen/student_attendance_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/homework_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/result_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/event_photos_screen.dart';
import 'package:the_red_apple/student_dashborad_screen/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotesAndShow();
    });
  }

  Future<void> _checkNotesAndShow() async {
    final studentMedium = widget.studentData['Medium'];
    final studentClass = widget.studentData['Class Name'];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final snapshot = await FirebaseFirestore.instance
        .collection('notes')
        .where('medium', isEqualTo: studentMedium)
        .where('class', isEqualTo: studentClass)
        .where('date', isEqualTo: today)
        .get();

    if (snapshot.docs.isNotEmpty && mounted) {
      final note = snapshot.docs.first.data();

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.7, // ✅ sirf 70% screen height
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Date sabse upar
                  Text(
                    "Date: ${note['date']}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Title
                  Text(
                    note['title'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00B4D8), // title color
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Content (scrollable box)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4D8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note['content'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }



  List<Widget> get _screens => [
    StudentAttendanceScreen(
      studentId: '',
      studentName: widget.studentData['Student Name'] ?? '',
      className: widget.studentData['Class Name'] ?? '',
      medium: widget.studentData['Medium'] ?? '',
      mobileNumber: widget.studentData['Mobile Number'] ?? '',
    ),
    HomeworkScreen(studentData: widget.studentData),
    ResultScreen(studentData: widget.studentData),
    EventPhotosScreen(),
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(_screens.length, (index) => _screens[index]),
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
        bottomBarItems: List.generate(_icons.length, (index) {
          return BottomBarItem(
            inActiveItem: Icon(_icons[index], color: Colors.grey[600]),
            activeItem: Icon(_icons[index], color: Colors.white),
            itemLabel: _labels[index],
          );
        }),
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      )
          : null,
    );
  }
}
