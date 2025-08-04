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
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    fetchStudentAttendance();
  }

  Future<void> fetchStudentAttendance() async {
    final classId = widget.studentData['class_id'];
    final studentId = widget.studentData['id'];

    final datesSnapshot = await FirebaseFirestore.instance
        .collection('attendance_records')
        .doc(classId)
        .collection('dates')
        .get();

    Map<DateTime, bool> tempMap = {};

    for (var doc in datesSnapshot.docs) {
      final data = doc.data();
      final dateStr = doc.id;

      if (data.containsKey('students')) {
        final studentMap = data['students'] as Map<String, dynamic>;
        if (studentMap.containsKey(studentId)) {
          DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
          tempMap[date] = studentMap[studentId] == true;
        }
      }
    }

    setState(() {
      attendanceMap = tempMap;
    });
  }

  Widget buildMarker(DateTime day) {
    if (!attendanceMap.containsKey(day)) return const SizedBox();

    final isPresent = attendanceMap[day]!;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPresent ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance Calendar'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              return buildMarker(day);
            },
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
