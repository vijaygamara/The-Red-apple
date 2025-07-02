// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class Studentsignup extends StatefulWidget {
//   const Studentsignup({super.key});
//
//   @override
//   State<Studentsignup> createState() => _StudentsignupState();
// }
//
// class _StudentsignupState extends State<Studentsignup> {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//
//   String? verificationId;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Student Signup',
//           style: TextStyle(fontSize: 30, color: Colors.black),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 30),
//             SizedBox(width: 100,),
//             TextField(
//               controller: phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "Phone Number",
//                 hintText: "Enter Phone Number",
//                 filled: true,
//                 fillColor: Colors.white,
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 String phone = phoneController.text.trim();
//                 if (!phone.startsWith('+')) {
//                   phone = '+91$phone'; // Assuming India code
//                 }
//
//                 await FirebaseAuth.instance.verifyPhoneNumber(
//                   phoneNumber: phone,
//                   verificationCompleted: (PhoneAuthCredential credential) async {
//                     await FirebaseAuth.instance.signInWithCredential(credential);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Phone number automatically verified")),
//                     );
//                   },
//                   verificationFailed: (FirebaseAuthException ex) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Verification failed: ${ex.message}")),
//                     );
//                   },
//                   codeSent: (String verId, int? resendToken) {
//                     setState(() {
//                       verificationId = verId;
//                     });
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("OTP sent")),
//                     );
//                   },
//                   codeAutoRetrievalTimeout: (String verId) {
//                     verificationId = verId;
//                   },
//                   timeout: const Duration(seconds: 60),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.all(15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text(
//                 'Send OTP',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "OTP",
//                 hintText: "Enter OTP",
//                 filled: true,
//                 fillColor: Colors.white,
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 if (verificationId == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Please request OTP first")),
//                   );
//                   return;
//                 }
//
//                 try {
//                   PhoneAuthCredential credential = PhoneAuthProvider.credential(
//                     verificationId: verificationId!,
//                     smsCode: otpController.text.trim(),
//                   );
//
//                   await FirebaseAuth.instance.signInWithCredential(credential);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Phone number verified successfully")),
//                   );
//                 } catch (ex) {
//                   debugPrint('OTP Error: $ex');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("OTP verification failed")),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.all(15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text(
//                 'Verify OTP',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
