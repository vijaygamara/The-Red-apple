import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_red_apple/student_dashborad_screen/student_dashborad.dart';
import 'dart:convert';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  final String sharedPassword = "109996";

  @override
  void initState() {
    super.initState();
    _checkLogin(); // 👈 Auto-login check on startup
  }

  // Agar student already login hai to direct dashboard open karenge
  Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentDataStr = prefs.getString("studentData");

    debugPrint("📂 Saved studentData: $studentDataStr");

    if (studentDataStr != null) {
      Map<String, dynamic> studentData = jsonDecode(studentDataStr);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboard(studentData: studentData),
          ),
        );
      });
    }
  }

  void _loginStudent() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    if (password != sharedPassword) {
      _showMessage("Invalid password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('students')
          .where('Mobile Number', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final studentData = query.docs.first.data();

        await saveLogin(phone, studentData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboard(
              studentData: jsonDecode(jsonEncode(_buildSafeStudentData(phone, studentData))),
            ),
          ),
        );
      } else {
        _showMessage("No student found with this phone number");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> saveLogin(String phone, Map<String, dynamic> studentData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final safe = _buildSafeStudentData(phone, studentData);
    await prefs.setString('phone', phone);
    await prefs.setString('studentData', jsonEncode(safe));
    debugPrint("✅ Saved phone: $phone");
    debugPrint("✅ Student Data saved (safe)");
  }

  Map<String, dynamic> _buildSafeStudentData(String phone, Map<String, dynamic> studentData) {
    return {
      'Student Name': studentData['Student Name']?.toString() ?? '',
      'Parents Name': studentData['Parents Name']?.toString() ?? '',
      'Class Name': studentData['Class Name']?.toString() ?? '',
      'Medium': studentData['Medium']?.toString() ?? '',
      'Address': studentData['Address']?.toString() ?? '',
      'Mobile Number': studentData['Mobile Number']?.toString() ?? phone,
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
        if (isKeyboardOpen) {
          FocusScope.of(context).unfocus();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                  Color(0xFF90CAF9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "The Red Apple Pre-school",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black45,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Student Login",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInputField(
                        controller: phoneController,
                        hint: "Enter Phone Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: passwordController,
                        hint: "Enter Password",
                        icon: Icons.lock,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginStudent,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.blueAccent)
                              : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
