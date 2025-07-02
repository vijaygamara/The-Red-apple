// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:the_red_apple/StudentHomePage/student_home.dart';
//
// class StudentOtp extends StatefulWidget {
//   final String verificationid;
//   const StudentOtp({super.key, required this.verificationid});
//
//   @override
//   State<StudentOtp> createState() => _StudentOtpState();
// }
//
// class _StudentOtpState extends State<StudentOtp> {
//   final TextEditingController otpController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: otpController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Enter The OTP",
//                   suffixIcon: const Icon(Icons.phone),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     PhoneAuthCredential credential =
//                     PhoneAuthProvider.credential(
//                         verificationId: widget.verificationid,
//                         smsCode: otpController.text.trim());
//                     await FirebaseAuth.instance
//                         .signInWithCredential(credential)
//                         .then((value) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => StudentHome()),
//                       );
//                     });
//                   } catch (ex) {
//                     debugPrint('OTP Error: $ex');
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("OTP verification failed")),
//                     );
//                   }
//                 },
//                 child: const Text('Verify OTP'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
