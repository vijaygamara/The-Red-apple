// // import 'package:flutter/material.dart';
// //
// // class UserMainScreen extends StatefulWidget {
// //   const UserMainScreen({super.key});
// //
// //   @override
// //   State<UserMainScreen> createState() => _UserMainScreenState();
// // }
// //
// // class _UserMainScreenState extends State<UserMainScreen> {
// //   int _selectedIndex = 0;
// //
// //   final List<Widget> _screens = [
// //     const UserDashboard(),
// //     const AttendanceScreen(),
// //     const ResultScreen(),
// //     const HomeworkScreen(),
// //     const GalleryScreen(),
// //     const ProfileScreen(),
// //   ];
// //
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: _screens[_selectedIndex],
// //       bottomNavigationBar: BottomNavigationBar(
// //         currentIndex: _selectedIndex,
// //         onTap: _onItemTapped,
// //         type: BottomNavigationBarType.fixed,
// //         selectedItemColor: const Color(0xFFff6a00),
// //         unselectedItemColor: Colors.grey,
// //         backgroundColor: Colors.white,
// //         elevation: 8,
// //         items: const [
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.dashboard),
// //             label: 'Dashboard',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.check_circle),
// //             label: 'Attendance',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.assessment),
// //             label: 'Results',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.assignment),
// //             label: 'Homework',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.photo_library),
// //             label: 'Gallery',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.person),
// //             label: 'Profile',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// // class UserDashboard extends StatelessWidget {
// //   const UserDashboard({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         if (FocusManager.instance.primaryFocus != null &&
// //             FocusManager.instance.primaryFocus!.hasFocus) {
// //           FocusManager.instance.primaryFocus!.unfocus();
// //           return false;
// //         }
// //         return true;
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.transparent,
// //         body: Container(
// //           width: double.infinity,
// //           height: double.infinity,
// //           decoration: const BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [Color(0xFFff6a00), Color(0xFFee0979)],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 80),
// //               // User Welcome Section
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 20),
// //                 child: Row(
// //                   children: [
// //                     const CircleAvatar(
// //                       radius: 30,
// //                       backgroundColor: Colors.white,
// //                       child: Icon(Icons.person, size: 35, color: Color(0xFFff6a00)),
// //                     ),
// //                     const SizedBox(width: 15),
// //                     const Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             "Welcome Back!",
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.normal,
// //                             ),
// //                           ),
// //                           Text(
// //                             "Student Name",
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 40),
// //               Expanded(
// //                 child: LayoutBuilder(
// //                   builder: (context, constraints) {
// //                     double itemWidth = (constraints.maxWidth / 2) - 24;
// //
// //                     return SingleChildScrollView(
// //                       padding: const EdgeInsets.all(16),
// //                       child: Wrap(
// //                         spacing: 16,
// //                         runSpacing: 16,
// //                         alignment: WrapAlignment.center,
// //                         children: [
// //                           _buildCard(
// //                             context,
// //                             title: "My Attendance",
// //                             icon: Icons.calendar_today,
// //                             width: itemWidth,
// //                             value: "85%",
// //                             onTap: () {
// //                               // Navigate to attendance detail
// //                             },
// //                           ),
// //                           _buildCard(
// //                             context,
// //                             title: "My Results",
// //                             icon: Icons.assessment,
// //                             width: itemWidth,
// //                             value: "A Grade",
// //                             onTap: () {
// //                               // Navigate to results
// //                             },
// //                           ),
// //                           _buildCard(
// //                             context,
// //                             title: "Homework",
// //                             icon: Icons.assignment,
// //                             width: itemWidth,
// //                             value: "3 Pending",
// //                             onTap: () {
// //                               // Navigate to homework
// //                             },
// //                           ),
// //                           _buildCard(
// //                             context,
// //                             title: "Gallery",
// //                             icon: Icons.photo_library,
// //                             width: itemWidth,
// //                             value: "New Photos",
// //                             onTap: () {
// //                               // Navigate to gallery
// //                             },
// //                           ),
// //                           _buildCard(
// //                             context,
// //                             title: "Notifications",
// //                             icon: Icons.notifications,
// //                             width: itemWidth,
// //                             value: "5 New",
// //                             onTap: () {
// //                               // Navigate to notifications
// //                             },
// //                           ),
// //                           _buildCard(
// //                             context,
// //                             title: "Profile",
// //                             icon: Icons.person,
// //                             width: itemWidth,
// //                             value: "View Details",
// //                             onTap: () {
// //                               // Navigate to profile
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCard(
// //       BuildContext context, {
// //         required String title,
// //         String value = "",
// //         required IconData icon,
// //         required double width,
// //         VoidCallback? onTap,
// //       }) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         width: width,
// //         padding: const EdgeInsets.all(15),
// //         decoration: BoxDecoration(
// //           color: Colors.white.withOpacity(0.2),
// //           borderRadius: BorderRadius.circular(20),
// //           border: Border.all(color: Colors.white.withOpacity(0.3)),
// //           boxShadow: const [
// //             BoxShadow(
// //               color: Colors.black26,
// //               blurRadius: 10,
// //               offset: Offset(0, 6),
// //             )
// //           ],
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(icon, color: Colors.white, size: 45),
// //             const SizedBox(height: 10),
// //             Text(
// //               title,
// //               textAlign: TextAlign.center,
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //               ),
// //             ),
// //             if (value.isNotEmpty) ...[
// //               const SizedBox(height: 8),
// //               Text(
// //                 value,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //             ]
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// // // Placeholder screens
// // class AttendanceScreen extends StatelessWidget {
// //   const AttendanceScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(
// //       body: Center(
// //         child: Text('Attendance Screen', style: TextStyle(fontSize: 24)),
// //       ),
// //     );
// //   }
// // }
// //
// // class ResultScreen extends StatelessWidget {
// //   const ResultScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(
// //       body: Center(
// //         child: Text('Result Screen', style: TextStyle(fontSize: 24)),
// //       ),
// //     );
// //   }
// // }
// //
// // class HomeworkScreen extends StatelessWidget {
// //   const HomeworkScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(
// //       body: Center(
// //         child: Text('Homework Screen', style: TextStyle(fontSize: 24)),
// //       ),
// //     );
// //   }
// // }
// //
// // class GalleryScreen extends StatelessWidget {
// //   const GalleryScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(
// //       body: Center(
// //         child: Text('Gallery Screen', style: TextStyle(fontSize: 24)),
// //       ),
// //     );
// //   }
// // }
// //
// // class ProfileScreen extends StatelessWidget {
// //   const ProfileScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(
// //       body: Center(
// //         child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
//
// class WelcomeStudentScreen extends StatelessWidget {
//   const WelcomeStudentScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFff6a00), Color(0xFFee0979)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Logo/Icon
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: const Icon(
//                   Icons.school,
//                   size: 80,
//                   color: Colors.white,
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Welcome Text
//               const Text(
//                 "Welcome to",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w300,
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               const Text(
//                 "Student Portal",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Student Name
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircleAvatar(
//                       radius: 25,
//                       backgroundColor: Colors.white,
//                       child: Icon(Icons.person, color: Color(0xFFff6a00), size: 30),
//                     ),
//                     SizedBox(width: 15),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Hello,",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           "Student Name",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 60),
//
//               // Continue Button
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const StudentMainScreen()),
//                   );
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 50),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Continue to Dashboard",
//                         style: TextStyle(
//                           color: Color(0xFFff6a00),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Icon(
//                         Icons.arrow_forward,
//                         color: Color(0xFFff6a00),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class StudentMainScreen extends StatefulWidget {
//   const StudentMainScreen({super.key});
//
//   @override
//   State<StudentMainScreen> createState() => _StudentMainScreenState();
// }
//
// class _StudentMainScreenState extends State<StudentMainScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _screens = [
//     const DashboardTab(),
//     const AttendanceTab(),
//     const ResultsTab(),
//     const HomeworkTab(),
//     const GalleryTab(),
//     const ProfileTab(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: const Color(0xFFff6a00),
//           unselectedItemColor: Colors.grey,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           selectedFontSize: 12,
//           unselectedFontSize: 10,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard),
//               label: 'Dashboard',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.check_circle_outline),
//               label: 'Attendance',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.assessment),
//               label: 'Results',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.assignment),
//               label: 'Homework',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.photo_library),
//               label: 'Gallery',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Dashboard Tab
// class DashboardTab extends StatelessWidget {
//   const DashboardTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFff6a00), Color(0xFFee0979)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               child: const Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.person, color: Color(0xFFff6a00)),
//                   ),
//                   SizedBox(width: 15),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Good Morning!",
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       Text(
//                         "Student Name",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Quick Stats Cards
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(top: 20),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Quick Overview",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Expanded(
//                         child: GridView.count(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 15,
//                           mainAxisSpacing: 15,
//                           children: [
//                             _buildDashboardCard("Attendance", "85%", Icons.calendar_today, Colors.green),
//                             _buildDashboardCard("Results", "A Grade", Icons.assessment, Colors.blue),
//                             _buildDashboardCard("Homework", "3 Pending", Icons.assignment, Colors.orange),
//                             _buildDashboardCard("Notifications", "5 New", Icons.notifications, Colors.red),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: color, size: 40),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Attendance Tab
// class AttendanceTab extends StatelessWidget {
//   const AttendanceTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Attendance"),
//         backgroundColor: const Color(0xFFff6a00),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.calendar_today, size: 80, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               "Attendance Details",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("Your attendance record will appear here"),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Results Tab
// class ResultsTab extends StatelessWidget {
//   const ResultsTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Results"),
//         backgroundColor: const Color(0xFFff6a00),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.assessment, size: 80, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               "Results & Grades",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("Your exam results will appear here"),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Homework Tab
// class HomeworkTab extends StatelessWidget {
//   const HomeworkTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Homework"),
//         backgroundColor: const Color(0xFFff6a00),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.assignment, size: 80, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               "Homework & Assignments",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("Your homework assignments will appear here"),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Gallery Tab
// class GalleryTab extends StatelessWidget {
//   const GalleryTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Gallery"),
//         backgroundColor: const Color(0xFFff6a00),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.photo_library, size: 80, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               "Photo Gallery",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("School photos and events will appear here"),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Profile Tab
// class ProfileTab extends StatelessWidget {
//   const ProfileTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Profile"),
//         backgroundColor: const Color(0xFFff6a00),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundColor: Color(0xFFff6a00),
//               child: Icon(Icons.person, size: 60, color: Colors.white),
//             ),
//             SizedBox(height: 20),
//             Text(
//               "Student Profile",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("Your profile information will appear here"),
//           ],
//         ),
//       ),
//     );
//   }
// }