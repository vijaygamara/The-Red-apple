import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  int presentDays = 0;
  int absentDays = 0;

  @override
  void initState() {
    super.initState();
    fetchStudentAttendance();
  }

  Future<void> fetchStudentAttendance() async {
    final classId = widget.studentData['class_id'];
    final studentId = widget.studentData['id'];

    print('Fetching attendance for classId: $classId, studentId: $studentId');

    final datesSnapshot = await FirebaseFirestore.instance
        .collection('attendance_records')
        .doc(classId)
        .collection('dates')
        .get();

    Map<DateTime, bool> tempMap = {};
    int tempPresent = 0;
    int tempAbsent = 0;

    for (var doc in datesSnapshot.docs) {
      final data = doc.data();
      final dateStr = doc.id;

      print('Date document id: $dateStr');
      print('Data: $data');

      if (data.containsKey('students')) {
        final studentMap = data['students'] as Map<String, dynamic>;
        if (studentMap.containsKey(studentId)) {
          DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
          bool isPresent = studentMap[studentId] == true;

          // Normalize date (strip time part)
          final normalizedDate = DateTime(date.year, date.month, date.day);

          tempMap[normalizedDate] = isPresent;

          if (isPresent) {
            tempPresent++;
          } else {
            tempAbsent++;
          }
        }
      }
    }

    print('Attendance map keys count: ${tempMap.length}');
    print('Present: $tempPresent, Absent: $tempAbsent');

    setState(() {
      attendanceMap = tempMap;
      presentDays = tempPresent;
      absentDays = tempAbsent;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = presentDays + absentDays;
    double attendancePercent =
    totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Attendance Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(height: 4),
                            Text(
                              "$presentDays",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text("Present"),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.cancel, color: Colors.red),
                            const SizedBox(height: 4),
                            Text(
                              "$absentDays",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text("Absent"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: attendancePercent / 100,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Attendance Rate: ${attendancePercent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: attendancePercent >= 75
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📅 Calendar
            Expanded(
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
                selectedDayPredicate: (day) => false,
                onDaySelected: (selectedDay, focusedDay) {
                  final dayKey =
                  DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  if (attendanceMap.containsKey(dayKey)) {
                    bool isPresent = attendanceMap[dayKey]!;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "${selectedDay.toLocal().toIso8601String().substring(0,10)} → ${isPresent ? "Present" : "Absent"}"),
                        backgroundColor:
                        isPresent ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "${selectedDay.toLocal().toIso8601String().substring(0,10)} → No Data"),
                        backgroundColor: Colors.grey,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final dayKey = DateTime(day.year, day.month, day.day);
                    final isPresent = attendanceMap[dayKey];
                    if (isPresent == null) return null;

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isPresent ? Colors.green[200] : Colors.red[200],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isPresent
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
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
                calendarStyle: const CalendarStyle(
                  weekendTextStyle: TextStyle(color: Colors.red),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  todayTextStyle: TextStyle(color: Colors.white),
                  isTodayHighlighted: true,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                LegendDot(color: Colors.green, label: "Present"),
                LegendDot(color: Colors.red, label: "Absent"),
                LegendDot(color: Colors.grey, label: "No Data"),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
