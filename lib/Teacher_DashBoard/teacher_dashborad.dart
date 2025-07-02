import 'package:flutter/material.dart';
import 'package:the_red_apple/Classis_Detail_Screen/classis_screen.dart';
import 'package:the_red_apple/Students_Screen/students_screen.dart';

class TeacherDashborad extends StatefulWidget {
  const TeacherDashborad({super.key});

  @override
  State<TeacherDashborad> createState() => _TeacherDashboradState();
}

class _TeacherDashboradState extends State<TeacherDashborad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFff6a00), // Vibrant orange
              Color(0xFFee0979), // Pinkish red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSummaryRow(),
              const SizedBox(height: 250),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildGridRecords(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 120),
          Wrap(
            spacing: 15,
            runSpacing: 20,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildSummaryCard("Total Students", "120", Icons.people),
              _buildSummaryCard("Attendance", "95%", Icons.check_circle),
              _buildSummaryCard("Working Days", "180", Icons.calendar_today),
              _buildSummaryCard("Gallery", "180", Icons.photo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 30,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 35),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridRecords() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildGridButton(
          title: 'Class Records',
          icon: Icons.class_,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClassisScreen()),
            );
          },
        ),
        _buildGridButton(
          title: 'Student Records',
          icon: Icons.school,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGridButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
