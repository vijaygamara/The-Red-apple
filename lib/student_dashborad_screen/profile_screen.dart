import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_red_apple/student_dashborad_screen/student_login.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const ProfileScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Extra bottom space so content (especially Logout) doesn't go under bottom bar
    final extraBottomPadding = media.padding.bottom + 90;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          '🎓 My Student Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + extraBottomPadding),
          children: [
            buildBox('🧒 Name', studentData['Student Name']),
            buildBox('👨‍👩‍👧 Parents Name', studentData['Parents Name']),
            buildBox('🏫 Class', studentData['Class Name']),
            buildBox('🗣️ Medium', studentData['Medium']),
            buildBox('🏠 Address', studentData['Address']),
            buildBox('📞 Mobile', studentData['Mobile Number']),

            // ✅ Logout Button Only
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCAF0F8), Color(0xFFE0FBFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: InkWell(
                  onTap: () {
                    _logout(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Fixed logout function
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // sabhi saved keys delete ho jaayenge

    // login page par bhejo aur puri navigation stack clear karo
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StudentLogin()),
          (route) => false,
    );
  }

  Widget buildBox(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCAF0F8), Color(0xFFE0FBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0077B6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value ?? "-",
              style: GoogleFonts.poppins(
                fontSize: 16.5,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
