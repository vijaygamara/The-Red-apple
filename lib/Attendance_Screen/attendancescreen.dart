import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendancescreen extends StatefulWidget {
  final Map<String, dynamic>? attendanceData;

  const Attendancescreen({super.key, this.attendanceData});

  @override
  State<Attendancescreen> createState() => _AttendancescreenState();
}

class _AttendancescreenState extends State<Attendancescreen> {
  String? _selectedClass;
  List<String> classList = [];
  bool isLoadingClasses = true;

  DateTime selectedDate = DateTime.now();
  late TextEditingController dateController;

  Map<String, bool> attendanceMap = {}; // studentID -> true/false

  @override
  void initState() {
    super.initState();
    fetchClasses();

    dateController = TextEditingController(
      text: DateFormat('dd MMMM yyyy').format(selectedDate),
    );

    if (widget.attendanceData != null) {
      final data = widget.attendanceData!;
      _selectedClass = data['class'];
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> fetchClasses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('classes').get();

      final classes = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['className'] as String?)
          .where((className) => className != null && className.isNotEmpty)
          .cast<String>()
          .toList();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      setState(() {
        isLoadingClasses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      helpText: 'Select attendance date',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.red,
            colorScheme: const ColorScheme.light(primary: Colors.red),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd MMMM yyyy').format(selectedDate);
      });
    }
  }

  void _saveAttendance() async {
    if (_selectedClass == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    for (final entry in attendanceMap.entries) {
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(_selectedClass)
          .collection(dateStr)
          .doc(entry.key)
          .set({
        'present': entry.value,
        'studentId': entry.key,
        'class': _selectedClass,
        'date': dateStr,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Dropdown
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedClass,
                  items: classList
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedClass = v;
                      attendanceMap.clear();
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date Picker
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: dateController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: const OutlineInputBorder(),
                              hintText: 'Select Date',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            onTap: () => _selectDate(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Student List
            if (_selectedClass != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Students of $_selectedClass',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 400,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .where('Class Name', isEqualTo: _selectedClass)
                          .orderBy('Student Name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No students found.'));
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final studentDoc = docs[index];
                            final studentData = studentDoc.data() as Map<String, dynamic>;
                            final studentName = studentData['Student Name'] ?? 'Unknown';
                            final studentId = studentDoc.id;

                            final isPresent = attendanceMap[studentId];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Student Name
                                  Expanded(
                                    child: Text(
                                      studentName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ),

                                  // ✅ Present Button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        attendanceMap[studentId] = true;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isPresent == true ? Colors.black : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // ❌ Absent Button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        attendanceMap[studentId] = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isPresent == false ? Colors.black : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _saveAttendance,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Attendance"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
