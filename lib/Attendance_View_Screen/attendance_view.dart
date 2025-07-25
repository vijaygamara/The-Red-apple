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
            .collection('students')
            .where('class_id', isEqualTo: doc.id)
            .get();

        final totalStudents = studentsSnapshot.size;
        classData['total'] = totalStudents;

        // Get today's attendance
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final attendanceSnapshot = await FirebaseFirestore.instance
            .collection('attendance_records')
            .doc(doc.id)
            .collection('daily_records')
            .where('date', isEqualTo: today)
            .get();

        int present = 0;
        if (attendanceSnapshot.docs.isNotEmpty) {
          final students = attendanceSnapshot.docs.first['students'] as Map<String, dynamic>? ?? {};
          present = students.values.where((v) => v['present'] == true).length;
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
  DateTime selectedDate = DateTime.now();
  List<DocumentSnapshot> classStudents = [];
  Map<String, dynamic> attendanceData = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _fetchClassStudents();
    await _fetchAttendanceDates();
    await _fetchAttendanceForSelectedDate();
  }

  Future<void> _fetchClassStudents() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('class_id', isEqualTo: widget.classData['id'])
          .orderBy('Student Name')
          .get();

      setState(() {
        classStudents = snapshot.docs;
      });
    } catch (e) {
      _showError('Error loading students: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAttendanceDates() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(widget.classData['id'])
          .collection('daily_records')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        availableDates = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      _showError('Error loading attendance dates: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAttendanceForSelectedDate() async {
    if (classStudents.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final doc = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(widget.classData['id'])
          .collection('daily_records')
          .doc(dateStr)
          .get();

      setState(() {
        attendanceData = doc.exists ? doc.data() ?? {} : {};
      });
    } catch (e) {
      _showError('Error loading attendance: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildDateChip(DateTime date) {
    final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(selectedDate);
    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    return GestureDetector(
      onTap: () {
        setState(() => selectedDate = date);
        _fetchAttendanceForSelectedDate();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd').format(date),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (classStudents.isEmpty) return const Center(child: Text("No students in this class"));

    final studentsMap = attendanceData['students'] as Map<String, dynamic>? ?? {};
    final presentCount = studentsMap.values.where((v) => v['present'] == true).length;
    final absentCount = classStudents.length - presentCount;

    return Column(
      children: [
        // Attendance Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total', classStudents.length, Colors.blue),
              _buildSummaryItem('Present', presentCount, Colors.green),
              _buildSummaryItem('Absent', absentCount, Colors.red),
            ],
          ),
        ),

        // Student List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: classStudents.length,
          itemBuilder: (context, index) {
            final student = classStudents[index];
            final studentData = student.data() as Map<String, dynamic>;
            final isPresent = studentsMap[student.id]?['present'] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPresent ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    isPresent ? Icons.check : Icons.close,
                    color: isPresent ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  studentData['Student Name'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // subtitle: Text(
                //   'ID: ${student.id}',
                //   style: const TextStyle(fontSize: 12),
                // ),
                trailing: Text(
                  isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<DateTime> _generateDateRange() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, now.day); // Last month
    final endDate = now.add(const Duration(days: 7)); // Next week
    final days = endDate.difference(startDate).inDays;

    return List.generate(days, (i) => startDate.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = _generateDateRange();
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

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
          // Class Info
          Padding(
            padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Horizontal Date Picker
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: dateRange.map(_buildDateChip).toList(),
            ),
          ),

          // Selected Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Student List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (availableDates.isNotEmpty && !availableDates.contains(dateStr))
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No attendance recorded for this date"),
                    ),
                  _buildStudentList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
