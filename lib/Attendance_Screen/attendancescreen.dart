
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
      final attendanceRef = FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(selectedClass!['id'])
          .collection('dates')
          .doc(dateStr);

      Map<String, dynamic> attendanceData = {
        'class_id': selectedClass!['id'],
        'class_name': selectedClass!['className'],
        'medium': selectedMedium,
        'date': dateStr,
        'timestamp': FieldValue.serverTimestamp(),
        'students': {},
      };

      attendanceMap.forEach((studentId, present) {
        attendanceData['students'][studentId] = present;
      });

      await attendanceRef.set(attendanceData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully!')),
      );

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

            // Date picker
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

            // Student List with Attendance Marking
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
                    final data = doc.data() as Map<String, dynamic>;
                    return data['Class Name'] == selectedClass!['className'] &&
                        data['Medium'] == selectedMedium;
                  }).toList();


                  if (students.isEmpty) {
                    return const Center(child: Text('No students in this class'));
                  }

                  for (var student in students) {
                    attendanceMap.putIfAbsent(student.id, () => false);
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final data = student.data() as Map<String, dynamic>;
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
                                  (data['Student Name'] ?? 'S')[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(data['Student Name'] ?? 'No Name'),
                              ),
                              Row(
                                children: [
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
