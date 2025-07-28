// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
//
// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});
//
//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }
//
// class _AttendanceScreenState extends State<AttendanceScreen> {
//   String? selectedMedium;
//   List<String> mediumList = ['English Medium', 'Gujarati Medium'];
//
//   Map<String, dynamic>? selectedClass;
//   List<Map<String, dynamic>> classList = [];
//
//   bool isLoadingClasses = false;
//   bool isSaving = false;
//
//   DateTime selectedDate = DateTime.now();
//   late TextEditingController dateController;
//
//   final Map<String, bool> attendanceMap = {};
//
//   @override
//   void initState() {
//     super.initState();
//     dateController = TextEditingController(
//       text: DateFormat('dd MMMM yyyy').format(selectedDate),
//     );
//   }
//
//   @override
//   void dispose() {
//     dateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> fetchClassesByMedium(String medium) async {
//     setState(() {
//       isLoadingClasses = true;
//       classList = [];
//       selectedClass = null;
//       attendanceMap.clear();
//     });
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('classes')
//           .where('medium', isEqualTo: medium)
//           .get();
//
//       final classes = snapshot.docs.map((doc) {
//         return {
//           'id': doc.id,
//           'className': doc['className'] ?? '',
//         };
//       }).toList();
//
//       setState(() {
//         classList = classes;
//         isLoadingClasses = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoadingClasses = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load classes: $e')),
//       );
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         dateController.text = DateFormat('dd MMMM yyyy').format(selectedDate);
//       });
//     }
//   }
//
//   Future<void> _saveAttendance() async {
//     if (selectedMedium == null || selectedClass == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select Medium and Class')),
//       );
//       return;
//     }
//
//     if (attendanceMap.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please mark attendance for students')),
//       );
//       return;
//     }
//
//     setState(() {
//       isSaving = true;
//     });
//
//     final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
//
//     try {
//       final batch = FirebaseFirestore.instance.batch();
//       final attendanceCollection = FirebaseFirestore.instance
//           .collection('attendance')
//           .doc(selectedClass!['id'])
//           .collection(dateStr);
//
//       attendanceMap.forEach((studentId, present) {
//         final docRef = attendanceCollection.doc(studentId);
//         batch.set(docRef, {
//           'present': present,
//           'studentId': studentId,
//           'class': selectedClass!['className'],
//           'class_id': selectedClass!['id'],
//           'medium': selectedMedium,
//           'date': dateStr,
//         });
//       });
//
//       await batch.commit();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance saved successfully!')),
//       );
//
//       setState(() {
//         attendanceMap.clear();
//         selectedClass = null;
//         selectedMedium = null;
//         classList.clear();
//         isSaving = false;
//       });
//     } catch (e) {
//       setState(() {
//         isSaving = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving attendance: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Attendance',
//             style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//           ),
//           backgroundColor: Colors.red,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Medium", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
//               Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 elevation: 5,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: selectedMedium,
//                       isExpanded: true,
//                       hint: Text("Select Medium", style: GoogleFonts.alatsi(fontSize: 16)),
//                       items: mediumList.map((item) {
//                         return DropdownMenuItem<String>(
//                           value: item,
//                           child: Text(item, style: GoogleFonts.alatsi(fontSize: 16)),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedMedium = value;
//                           selectedClass = null;
//                           classList = [];
//                           attendanceMap.clear();
//                         });
//                         if (value != null) {
//                           fetchClassesByMedium(value);
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Text('Class', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
//               isLoadingClasses
//                   ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
//                   : Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: DropdownButtonFormField<Map<String, dynamic>>(
//                     decoration: const InputDecoration(
//                       labelText: 'Select Class',
//                       border: OutlineInputBorder(),
//                     ),
//                     value: selectedClass,
//                     items: classList.map((c) {
//                       return DropdownMenuItem<Map<String, dynamic>>(
//                         value: c,
//                         child: Text(c['className'] ?? ''),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedClass = value;
//                         attendanceMap.clear();
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 25),
//               Text('Select Date', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
//               Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: TextFormField(
//                     controller: dateController,
//                     readOnly: true,
//                     decoration: const InputDecoration(
//                       prefixIcon: Icon(Icons.calendar_today),
//                       hintText: 'Select Date',
//                       border: OutlineInputBorder(),
//                     ),
//                     onTap: () => _selectDate(context),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 25),
//
//               if (selectedMedium != null && selectedClass != null)
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('students')
//                       .where('class_id', isEqualTo: selectedClass!['id'])
//                       .orderBy('Student Name')
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
//                     if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//                     if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No students found.'));
//
//                     final students = snapshot.data!.docs;
//
//                     return ListView.builder(
//                       itemCount: students.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         final studentDoc = students[index];
//                         final data = studentDoc.data() as Map<String, dynamic>;
//
//                         final StudentName = data['Student Name'] ?? 'Unknown';
//                         final studentId = studentDoc.id;
//                         final isPresent = attendanceMap[studentId];
//
//                         return Card(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: Colors.red,
//                                   child: Text(
//                                     StudentName.isNotEmpty ? StudentName[0].toUpperCase() : '?',
//                                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Text(
//                                     StudentName,
//                                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () => setState(() => attendanceMap[studentId] = true),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green,
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(
//                                         color: isPresent == true ? Colors.black : Colors.transparent,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     child: const Icon(Icons.check, color: Colors.white, size: 28),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 GestureDetector(
//                                   onTap: () => setState(() => attendanceMap[studentId] = false),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(
//                                         color: isPresent == false ? Colors.black : Colors.transparent,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     child: const Icon(Icons.close, color: Colors.white, size: 28),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//
//               const SizedBox(height: 30),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: isSaving ? null : _saveAttendance,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: isSaving
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                     "Save Attendance",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? selectedMedium;
  Map<String, dynamic>? selectedClass;
  final Map<String, bool> attendanceMap = {};
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> classList = [];

  bool isLoadingClasses = false;
  bool isSaving = false;

  late TextEditingController dateController;

  final List<String> mediumList = ['English Medium', 'Gujarati Medium'];
  final Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
      .collection('students')
      .orderBy('Student Name')
      .snapshots();

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(
      text: DateFormat('dd MMMM yyyy').format(selectedDate),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchClassesByMedium(String medium) async {
    setState(() {
      isLoadingClasses = true;
      selectedClass = null;
      attendanceMap.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('medium', isEqualTo: medium)
          .get();

      final classes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'className': doc['className'] ?? '',
          'medium': doc['medium'] ?? '',
        };
      }).toList();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
      return classes;
    } catch (e) {
      setState(() => isLoadingClasses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd MMMM yyyy').format(selectedDate);
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (selectedMedium == null || selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Medium and Class')),
      );
      return;
    }

    if (attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark attendance for students')),
      );
      return;
    }

    setState(() => isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final attendanceRef = FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(selectedClass!['id'])
          .collection('dates')
          .doc(dateStr);

      // Prepare the attendance data
      Map<String, dynamic> attendanceData = {
        'class_id': selectedClass!['id'],
        'class_name': selectedClass!['className'],
        'medium': selectedMedium,
        'date': dateStr,
        'timestamp': FieldValue.serverTimestamp(),
        'students': {},
      };

      // Add each student's attendance status
      attendanceMap.forEach((studentId, present) {
        attendanceData['students'][studentId] = present;
      });

      // Save the entire day's attendance as a single document
      await attendanceRef.set(attendanceData);

      // Also update each student's document with the attendance record
      await Future.wait(attendanceMap.entries.map((entry) async {
        final studentId = entry.key;
        final present = entry.value;
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .collection('attendance')
            .doc(dateStr)
            .set({
          'present': present,
          'date': dateStr,
          'class_id': selectedClass!['id'],
        });
      }));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully!')),
      );

      // Navigate back after saving
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving attendance: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Medium Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Medium', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedMedium,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: mediumList.map((medium) {
                    return DropdownMenuItem<String>(
                      value: medium,
                      child: Text(medium),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await fetchClassesByMedium(value);
                      setState(() {
                        selectedMedium = value;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Class Dropdown
            isLoadingClasses
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Class', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedClass,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: classList.map((classData) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: classData,
                      child: Text(classData['className']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                      attendanceMap.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: selectedClass == null
                  ? const Center(child: Text('Select class to load students'))
                  : StreamBuilder<QuerySnapshot>(
                stream: studentsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading students'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data!.docs.where((doc) {
                    return doc['Class Name'] == selectedClass!['className'] &&
                        doc['Medium'] == selectedMedium;
                  }).toList();


                  if (students.isEmpty) {
                    return const Center(child: Text('No students in this class'));
                  }

                  // Initialize attendance map with all students (default to false if not already set)
                  for (var student in students) {
                    attendanceMap.putIfAbsent(student.id, () => false);
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentId = student.id;
                      final isPresent = attendanceMap[studentId] ?? false;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isPresent ? Colors.green : Colors.red,
                                child: Text(
                                  student['Student Name'][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(student['Student Name']),
                              ),
                              Row(
                                children: [
                                  // Present Checkbox
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isPresent,
                                        onChanged: (value) {
                                          setState(() {
                                            attendanceMap[studentId] = true;
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                      const Text('Present'),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  // Absent Checkbox
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: !isPresent,
                                        onChanged: (value) {
                                          setState(() {
                                            attendanceMap[studentId] = false;
                                          });
                                        },
                                        activeColor: Colors.red,
                                      ),
                                      const Text('Absent'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save Attendance',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}