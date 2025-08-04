// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:the_red_apple/student_dashborad_screen/attendance_screen.dart';
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
//   int _selectedIndex = 0;
//   List<Widget> get _screens => [
//     AttendanceScreen(studentData: widget.studentData,), // You can also pass studentData here later if needed
//     HomeworkScreen(studentData: widget.studentData), // ✅ fixed
//     ResultScreen(studentData: widget.studentData,),
//     EventPhotosScreen(),
//     ProfileScreen(studentData: widget.studentData),
//   ];
//
//
//
//   final List<IconData> _icons = [
//     Icons.check_circle_outline,
//     Icons.book,
//     Icons.grade,
//     Icons.photo_library,
//     Icons.person,
//   ];
//
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
//     double width = MediaQuery.of(context).size.width;
//     double itemWidth = width / _icons.length;
//
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text(
//       //     _labels[_selectedIndex],
//       //     style: GoogleFonts.poppins(),
//       //   ),
//       //   centerTitle: true,
//       // ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           Container(
//             height: 75,
//             margin: const EdgeInsets.only(bottom: 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(40),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 10,
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: List.generate(_icons.length, (index) {
//                 final isSelected = index == _selectedIndex;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedIndex = index;
//                     });
//                   },
//                   child: SizedBox(
//                     width: itemWidth,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(height: isSelected ? 20 : 0),
//                         Icon(
//                           _icons[index],
//                           color: isSelected ? Colors.purple : Colors.grey,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _labels[index],
//                           style: GoogleFonts.poppins(
//                             fontSize: 11,
//                             color:
//                             isSelected ? Colors.purple : Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//
//           // Floating selected icon
//           Positioned(
//             bottom: 42,
//             left: (_selectedIndex * itemWidth) + (itemWidth / 2) - 26,
//             child: CircleAvatar(
//               radius: 26,
//               backgroundColor: Colors.white,
//               child: CircleAvatar(
//                 radius: 22,
//                 backgroundColor: Colors.purple,
//                 child: Icon(
//                   _icons[_selectedIndex],
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  int get maxCount => 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Your existing screens
  List<Widget> get _screens => [
    AttendanceScreen(studentData:widget.studentData),
    HomeworkScreen(studentData: widget.studentData),
    ResultScreen(studentData: widget.studentData),
    EventPhotosScreen(),
    ProfileScreen(studentData: widget.studentData),
  ];

  /// Your existing icons
  final List<IconData> _icons = [
    Icons.check_circle_outline,
    Icons.book,
    Icons.grade,
    Icons.photo_library,
    Icons.person,
  ];

  /// Your existing labels
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
        children: List.generate(_screens.length, (index) => _screens[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (_screens.length <= maxCount)
          ? AnimatedNotchBottomBar(
        /// Provide NotchBottomBarController
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,

        /// Changed to accentBlue for the notch
        notchColor: Colors.blueAccent,

        /// Remove margins for full-width effect
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,

        /// Custom label style with your Google Fonts
        itemLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),

        elevation: 10,

        /// Your custom bottom bar items using your existing icons and labels
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(
              _icons[0],
              color: Colors.grey[600],
            ),
            activeItem: Icon(
              _icons[0],
              color: Colors.white,
            ),
            itemLabel: _labels[0],
          ),
          BottomBarItem(
            inActiveItem: Icon(
              _icons[1],
              color: Colors.grey[600],
            ),
            activeItem: Icon(
              _icons[1],
              color: Colors.white,
            ),
            itemLabel: _labels[1],
          ),
          BottomBarItem(
            inActiveItem: Icon(
              _icons[2],
              color: Colors.grey[600],
            ),
            activeItem: Icon(
              _icons[2],
              color: Colors.white,
            ),
            itemLabel: _labels[2],
          ),
          BottomBarItem(
            inActiveItem: Icon(
              _icons[3],
              color: Colors.grey[600],
            ),
            activeItem: Icon(
              _icons[3],
              color: Colors.white,
            ),
            itemLabel: _labels[3],
          ),
          BottomBarItem(
            inActiveItem: Icon(
              _icons[4],
              color: Colors.grey[600],
            ),
            activeItem: Icon(
              _icons[4],
              color: Colors.white,
            ),
            itemLabel: _labels[4],
          ),
        ],
        onTap: (index) {
          /// Handle page navigation
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      )
          : null,
    );
  }
}
