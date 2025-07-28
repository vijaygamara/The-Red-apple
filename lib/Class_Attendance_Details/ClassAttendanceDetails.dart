// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
//
// class ClassAttendanceDetails extends StatefulWidget {
//   final Map<String, dynamic> classData;
//
//   const ClassAttendanceDetails({super.key, required this.classData});
//
//   @override
//   State<ClassAttendanceDetails> createState() => _ClassAttendanceDetailsState();
// }
//
// class _ClassAttendanceDetailsState extends State<ClassAttendanceDetails> {
//   List<String> availableDates = [];
//   bool isLoading = false;
//   DateTime selectedDate = DateTime.now();
//   List<DocumentSnapshot> classStudents = [];
//   Map<String, dynamic> attendanceData = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }
//
//   Future<void> _loadInitialData() async {
//     await _fetchClassStudents();
//     await _fetchAttendanceDates();
//     await _fetchAttendanceForSelectedDate();
//   }
//
//   Future<void> _fetchClassStudents() async {
//     setState(() => isLoading = true);
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('students')
//           .where('class_id', isEqualTo: widget.classData['id'])
//           .orderBy('Student Name')  // Make sure this field exists exactly as is
//           .get();
//
//       setState(() {
//         classStudents = snapshot.docs;
//       });
//     } catch (e) {
//       _showError('Error loading students: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> _fetchAttendanceDates() async {
//     setState(() => isLoading = true);
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('attendance_records')
//           .doc(widget.classData['id'])
//           .collection('daily_records')
//           .orderBy('date', descending: true)
//           .get();
//
//       setState(() {
//         availableDates = snapshot.docs.map((doc) => doc.id).toList();
//       });
//     } catch (e) {
//       _showError('Error loading attendance dates: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> _fetchAttendanceForSelectedDate() async {
//     if (classStudents.isEmpty) return;
//
//     setState(() => isLoading = true);
//     try {
//       final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
//       final doc = await FirebaseFirestore.instance
//           .collection('attendance_records')
//           .doc(widget.classData['id'])
//           .collection('daily_records')
//           .doc(dateStr)
//           .get();
//
//       setState(() {
//         attendanceData = doc.exists ? doc.data() as Map<String, dynamic> : {};
//       });
//     } catch (e) {
//       _showError('Error loading attendance: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   Widget _buildDateChip(DateTime date) {
//     final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
//         DateFormat('yyyy-MM-dd').format(selectedDate);
//     final isToday = DateFormat('yyyy-MM-dd').format(date) ==
//         DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//     return GestureDetector(
//       onTap: () {
//         setState(() => selectedDate = date);
//         _fetchAttendanceForSelectedDate();
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.red : Colors.grey[200],
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               DateFormat('EEE').format(date),
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               DateFormat('dd').format(date),
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             if (isToday)
//               Container(
//                 margin: const EdgeInsets.only(top: 2),
//                 width: 6,
//                 height: 6,
//                 decoration: const BoxDecoration(
//                   color: Colors.green,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStudentList() {
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (classStudents.isEmpty) return const Center(child: Text("No students in this class"));
//
//     // attendanceData['students'] is a map of studentId => {present: true/false}
//     final studentsMap = attendanceData['students'] as Map<String, dynamic>? ?? {};
//     final presentCount = studentsMap.values.where((v) => v['present'] == true).length;
//     final absentCount = classStudents.length - presentCount;
//
//     return Column(
//       children: [
//         // Attendance Summary
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummaryItem('Total', classStudents.length, Colors.blue),
//               _buildSummaryItem('Present', presentCount, Colors.green),
//               _buildSummaryItem('Absent', absentCount, Colors.red),
//             ],
//           ),
//         ),
//
//         // Student List
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: classStudents.length,
//           itemBuilder: (context, index) {
//             final student = classStudents[index];
//             final studentData = student.data() as Map<String, dynamic>;
//
//             // Try both common possibilities for field name:
//             final studentName = studentData['Student Name'] ??
//                 studentData['studentName'] ??
//                 'Unknown';
//
//             final isPresent = studentsMap[student.id]?['present'] ?? false;
//
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: isPresent ? Colors.green[100] : Colors.red[100],
//                   child: Icon(
//                     isPresent ? Icons.check : Icons.close,
//                     color: isPresent ? Colors.green : Colors.red,
//                   ),
//                 ),
//                 title: Text(
//                   studentName,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 trailing: Text(
//                   isPresent ? 'Present' : 'Absent',
//                   style: TextStyle(
//                     color: isPresent ? Colors.green : Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSummaryItem(String title, int count, Color color) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           count.toString(),
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<DateTime> _generateDateRange() {
//     final now = DateTime.now();
//     final startDate = DateTime(now.year, now.month - 1, now.day);
//     final endDate = now.add(const Duration(days: 7));
//     final days = endDate.difference(startDate).inDays;
//
//     return List.generate(days, (i) => startDate.add(Duration(days: i)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dateRange = _generateDateRange();
//     final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.classData['className'],
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.red,
//       ),
//       body: Column(
//         children: [
//           // Class Info
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.classData['className'],
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   widget.classData['medium'],
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//
//           // Horizontal Date Picker
//           SizedBox(
//             height: 70,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               children: dateRange.map(_buildDateChip).toList(),
//             ),
//           ),
//
//           // Selected Date
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Text(
//               DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//
//           // Student List
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   if (availableDates.isNotEmpty && !availableDates.contains(dateStr))
//                     const Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Text("No attendance recorded for this date"),
//                     ),
//                   _buildStudentList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
