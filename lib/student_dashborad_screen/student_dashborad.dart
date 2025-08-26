import 'dart:ui';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_red_apple/student_dashborad_screen/student_attendance_screen.dart';
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
  final _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _controller =
  NotchBottomBarController(index: 0);

  int get maxCount => 5;

  @override
  void initState() {
    super.initState();
    _deleteOldNotes(); // 👈 पहले पुराने notes delete होंगे
    _showLatestNote();
  }

  /// 🔴 Function: 24 घंटे से पुराने notes delete करना
  Future<void> _deleteOldNotes() async {
    try {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 24));

      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('createdAt', isLessThan: cutoff)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Error deleting old notes: $e");
    }
  }

  Future<void> _showLatestNote() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('medium', isEqualTo: widget.studentData['Medium'])
          .where('class', isEqualTo: widget.studentData['Class Name'])
          .where('sendNotification', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // 🔴 snapshot को list of map में convert करना
        final notesList = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNotesBottomSheet(context, notesList);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    }
  }


  void _showNotesBottomSheet(BuildContext context, List<Map<String, dynamic>> notes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(20),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  String formattedDate = "";
                  if (note['date'] != null) {
                    try {
                      if (note['date'] is DateTime) {
                        formattedDate =
                        "${note['date'].day}-${note['date'].month}-${note['date'].year}";
                      } else if (note['date'] is Timestamp) {
                        final d = (note['date'] as Timestamp).toDate();
                        formattedDate = "${d.day}-${d.month}-${d.year}";
                      } else {
                        formattedDate = note['date'].toString();
                      }
                    } catch (e) {
                      formattedDate = "";
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.note_alt,
                                color: Colors.black87, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note['title'] ?? "📘 New Note",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (formattedDate.isNotEmpty)
                                    Text(
                                      "📅 $formattedDate",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          note['content'] ?? "No content available",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    StudentAttendanceScreen(
      studentId: '',
      studentName: widget.studentData['Student Name'] ?? '',
      className: widget.studentData['Class Name'] ?? '',
      medium: widget.studentData['Medium'] ?? '',
      mobileNumber: widget.studentData['Mobile Number'] ?? '',
    ),
    HomeworkScreen(studentData: widget.studentData),
    ResultScreen(studentData: widget.studentData),
    EventPhotosScreen(),
    ProfileScreen(studentData: widget.studentData),
  ];

  final List<IconData> _icons = [
    Icons.check_circle_outline,
    Icons.book,
    Icons.grade,
    Icons.photo_library,
    Icons.person,
  ];

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
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Colors.blueAccent,
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 10,
        bottomBarItems: List.generate(_icons.length, (index) {
          return BottomBarItem(
            inActiveItem: Icon(
              _icons[index],
              color: Colors.grey[600],
            ),
            activeItem: Icon(
              _icons[index],
              color: Colors.white,
            ),
            itemLabel: _labels[index],
          );
        }),
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      )
          : null,
    );
  }
}
