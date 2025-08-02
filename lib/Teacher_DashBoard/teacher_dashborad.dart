import 'package:flutter/material.dart';
import 'package:the_red_apple/Classis_Detail_Screen/classis_screen.dart';
import 'package:the_red_apple/Event_Photo_Screen/event_photo.dart';
import 'package:the_red_apple/Home_work_Detail/homeworkdetail.dart';
import 'package:the_red_apple/Result_Entry_Screen/ResultEntryScreen.dart';
import 'package:the_red_apple/Result_Screen/result_screen.dart';
import 'package:the_red_apple/Students_Screen/students_screen.dart';

import '../Attendance_Screen/attendancescreen.dart';
import '../Attendance_View_Screen/attendance_view.dart';

class TeacherDashborad extends StatelessWidget {
  const TeacherDashborad({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (FocusManager.instance.primaryFocus != null &&
            FocusManager.instance.primaryFocus!.hasFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFff6a00), Color(0xFFee0979)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double itemWidth = (constraints.maxWidth / 2) - 24;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildCard(
                              context,
                              title: "Result",
                              icon: Icons.person,
                              width: itemWidth,
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=>ResultEntryScreen()));
                              }
                          ),
                          _buildCard(
                            context,
                            title: "Attendance",
                            icon: Icons.check_circle,
                            width: itemWidth,
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => AttendanceView()));
                            }
                          ),
                          _buildCard(
                            context,
                            title: "HomeWork",
                            icon: Icons.edit,
                            width: itemWidth,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Homeworkdetail()),
                              );
                            },
                          ),
                          _buildCard(
                            context,
                            title: "Gallery",
                            icon: Icons.photo,
                            width: itemWidth,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventPhoto()),
                              );
                            },
                          ),
                          _buildCard(
                            context,
                            title: "Class Records",
                            icon: Icons.class_,
                            width: itemWidth,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ClassisScreen()),
                              );
                            },
                          ),
                          _buildCard(
                            context,
                            title: "Student Records",
                            icon: Icons.school,
                            width: itemWidth,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const StudentsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        String value = "",
        required IconData icon,
        required double width,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 45),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}