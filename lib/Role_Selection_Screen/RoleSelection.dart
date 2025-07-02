// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:the_red_apple/Student_Signup_Screen/StudentSignup.dart';
// import 'package:the_red_apple/Teacher-Signup_Screen/TeacherSignup.dart';
//
// class Roleselection extends StatefulWidget {
//   const Roleselection({super.key});
//
//   @override
//   State<Roleselection> createState() => _RoleselectionState();
// }
//
// class _RoleselectionState extends State<Roleselection> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text('Welcome To The Red Apple',
//             style: GoogleFonts.almendra(fontSize: 30,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//             ),
//             ),
//             SizedBox(height: 50,),
//             Container(
//               height: 200,
//               width: 200,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('Assets/images/student.png'),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => Studentsignup()));
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.all(15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     )),
//                 child: const Text(
//                   'Student Signup..',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20,),
//             Divider(
//               thickness: 2,
//             ),
//             SizedBox(height: 50,),
//             Container(
//               height: 210,
//               width: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(image: AssetImage('Assets/images/img.png'))
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherSignup()));
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.pinkAccent,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.all(15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     )),
//                 child: const Text(
//                   'Teacher Signup..',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
