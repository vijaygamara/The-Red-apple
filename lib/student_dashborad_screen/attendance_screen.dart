import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const AttendanceScreen({super.key, required this.studentData});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Map<String, String> attendanceData = {};

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      String mobile = widget.studentData['Mobile Number'];
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('mobile_number', isEqualTo: mobile)
          .get();

      if (studentSnapshot.docs.isEmpty) return;

      final studentDoc = studentSnapshot.docs.first;
      final studentId = studentDoc.id;
      final classId = studentDoc['class_id'];

      final attendanceCollection = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(classId)
          .collection('dates')
          .get();

      Map<String, String> loadedData = {};
      for (var doc in attendanceCollection.docs) {
        final data = doc.data();
        if (data.containsKey('students') && data['students'][studentId] != null) {
          final bool present = data['students'][studentId] == true;
          loadedData[doc.id] = present ? 'Present' : 'Absent';
        }
      }

      setState(() => attendanceData = loadedData);
    } catch (e) {
      debugPrint('Attendance fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'Monthly Attendance',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            buildBox('🧒 Name', widget.studentData['Student Name']),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final dateKey = formatDate(day);
                  final status = attendanceData[dateKey];

                  if (status == null) return null;

                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: getColorForStatus(status),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Legend(color: Colors.green, label: 'Present'),
                Legend(color: Colors.red, label: 'Absent'),
                Legend(color: Colors.grey, label: 'No Data'),
              ],
            )
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Color getColorForStatus(String? status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildBox(String label, String? value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFCAF0F8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          Text(value ?? '-',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;

  const Legend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      ],
    );
  }
}
