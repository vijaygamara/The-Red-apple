import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const AttendanceScreen({super.key, required this.studentData});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Map<DateTime, bool> attendanceMap = {};
  String studentId = '';
  String classId = '';
  bool isLoading = true;

  int presentCount = 0;
  int absentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('Phone', isEqualTo: widget.studentData)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student not found')),
        );
        return;
      }

      final studentDoc = snapshot.docs.first;
      studentId = studentDoc.id;
      classId = studentDoc['class_id'];

      await fetchAttendanceData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> fetchAttendanceData() async {
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance_records')
        .doc(classId)
        .collection('dates')
        .get();

    Map<DateTime, bool> tempMap = {};
    int present = 0;
    int absent = 0;

    for (var doc in snapshot.docs) {
      final dateStr = doc.id; // yyyy-MM-dd
      if (!dateStr.startsWith(currentMonth)) continue;

      final data = doc.data();
      final students = data['students'] ?? {};
      final isPresent = students[studentId] == true;

      final date = DateTime.parse(dateStr);
      tempMap[date] = isPresent;

      if (isPresent) {
        present++;
      } else {
        absent++;
      }
    }

    setState(() {
      attendanceMap = tempMap;
      presentCount = present;
      absentCount = absent;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('My Attendance - $selectedMonth'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            calendarStyle: const CalendarStyle(
              markerSize: 5,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final status = attendanceMap[day];
                if (status == true) {
                  return _buildMarker(day, Colors.green);
                } else if (status == false) {
                  return _buildMarker(day, Colors.red);
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Summary - $selectedMonth',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryBox("Present", presentCount, Colors.green),
                        _buildSummaryBox("Absent", absentCount, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(DateTime day, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryBox(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
