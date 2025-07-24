import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Attendance_Screen/attendancescreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Attendance_Screen/attendancescreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Attendance_Screen/attendancescreen.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  List<Map<String, dynamic>> classList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchClassList();
  }

  Future<void> fetchClassList() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('classes').get();

      final List<Map<String, dynamic>> tempList = [];

      for (var doc in snapshot.docs) {
        final classData = {
          'id': doc.id,
          'className': doc['className'] ?? 'Unnamed',
          'medium': doc['medium'] ?? '',
        };

        // Get total students count
        final studentsSnapshot = await FirebaseFirestore.instance
            .collection('classes')
            .doc(doc.id)
            .collection('students')
            .get();

        final totalStudents = studentsSnapshot.size;
        classData['total'] = totalStudents;

        // Get today's attendance
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final attendanceSnapshot = await FirebaseFirestore.instance
            .collection('classes')
            .doc(doc.id)
            .collection('attendance')
            .doc(today)
            .get();

        int present = 0;
        if (attendanceSnapshot.exists) {
          final data = attendanceSnapshot.data() as Map<String, dynamic>;
          present = data.values.where((v) => v == 'Present').length;
        }

        classData['present'] = present;
        classData['absent'] = totalStudents - present;

        tempList.add(classData);
      }

      setState(() => classList = tempList);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading classes: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance Records",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AttendanceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : classList.isEmpty
          ? const Center(child: Text("No classes found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classList.length,
        itemBuilder: (context, index) {
          final classData = classList[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassAttendanceDetails(
                      classData: classData,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red[100],
                      child: Text(
                        classData['className'][0],
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData['className'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            classData['medium'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "Total: ${classData['total']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Present: ${classData['present']}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Absent: ${classData['absent']}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class ClassAttendanceDetails extends StatefulWidget {
  final Map<String, dynamic> classData;

  const ClassAttendanceDetails({super.key, required this.classData});

  @override
  State<ClassAttendanceDetails> createState() => _ClassAttendanceDetailsState();
}

class _ClassAttendanceDetailsState extends State<ClassAttendanceDetails> {
  List<String> availableDates = [];
  bool isLoading = false;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchAttendanceDates();
  }

  Future<void> fetchAttendanceDates() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(widget.classData['id'])
          .collection('dates')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        availableDates = snapshot.docs.map((doc) => doc.id).toList();
        if (availableDates.isNotEmpty) {
          selectedDate = availableDates.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance dates: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>> fetchAttendanceData(String date) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(widget.classData['id'])
          .collection('dates')
          .doc(date)
          .get();

      return doc.data() ?? {};
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
      return {};
    }
  }

  Future<List<DocumentSnapshot>> fetchStudentsWithAttendance(String date) async {
    final attendanceData = await fetchAttendanceData(date);
    if (attendanceData.isEmpty || !attendanceData.containsKey('students')) {
      return [];
    }

    final studentsMap = attendanceData['students'] as Map<String, dynamic>;
    final studentIds = studentsMap.keys.toList();

    if (studentIds.isEmpty) return [];

    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where(FieldPath.documentId, whereIn: studentIds)
        .get();

    return studentsSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.classData['className'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.classData['className'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.classData['medium'],
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableDates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = availableDates[index];
                final formattedDate = DateFormat('dd MMM').format(DateTime.parse(date));
                final isSelected = date == selectedDate;

                return ChoiceChip(
                  label: Text(
                    formattedDate,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.red,
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) {
                    setState(() => selectedDate = date);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : availableDates.isEmpty
                ? const Center(child: Text("No attendance records found"))
                : selectedDate == null
                ? const Center(child: Text("Select a date"))
                : FutureBuilder<List<DocumentSnapshot>>(
              future: fetchStudentsWithAttendance(selectedDate!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No attendance data for selected date'));
                }

                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchAttendanceData(selectedDate!),
                  builder: (context, attendanceSnapshot) {
                    if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final attendanceData = attendanceSnapshot.data ?? {};
                    final studentsMap =
                        attendanceData['students'] as Map<String, dynamic>? ?? {};

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['Student Name'] ?? 'Unknown';
                        final present = studentsMap[doc.id] == true;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                              present ? Colors.green : Colors.red,
                              child: Icon(
                                present ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              present ? 'Present' : 'Absent',
                              style: TextStyle(
                                color: present ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              DateFormat('dd MMM').format(
                                  DateTime.parse(selectedDate!)),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
