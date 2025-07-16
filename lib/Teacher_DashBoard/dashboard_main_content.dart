// import 'package:flutter/material.dart';
// import 'package:the_red_apple/Event_Photo_Screen/event_photo.dart';
// import 'package:the_red_apple/Home_work_Detail/homeworkdetail.dart';
// import 'package:the_red_apple/Result_Screen/result_screen.dart';
//
// class DashboardMainContent extends StatelessWidget {
//   const DashboardMainContent({super.key});
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
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             children: [
//               _buildCard(context, "Result", Icons.person, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ResultScreen()),
//                 );
//               }),
//               _buildCard(context, "Attendance", Icons.check_circle, () {
//                 // Future attendance feature
//               }),
//               _buildCard(context, "Homework", Icons.edit, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Homeworkdetail()),
//                 );
//               }),
//               _buildCard(context, "Gallery", Icons.photo, () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => EventPhoto()),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard(
//       BuildContext context,
//       String title,
//       IconData icon,
//       VoidCallback onTap,
//       ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: MediaQuery.of(context).size.width / 2 - 24,
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.white.withOpacity(0.3)),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 10,
//               offset: Offset(0, 6),
//             )
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 45),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
