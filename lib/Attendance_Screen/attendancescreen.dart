import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? selectedMedium;
  List<String> mediumList = ['English Medium', 'Gujarati Medium'];

  String? selectedClass;
  List<String> classList = [];

  bool isLoadingClasses = false;
  bool isSaving = false;

  DateTime selectedDate = DateTime.now();
  late TextEditingController dateController;

  final Map<String, bool> attendanceMap = {};

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

  Future<void> fetchClassesByMedium(String medium) async {
    setState(() {
      isLoadingClasses = true;
      classList = [];
      selectedClass = null;
      attendanceMap.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('medium', isEqualTo: medium)
          .get();

      final classes = snapshot.docs
          .map((doc) => doc.data()['className'] as String)
          .toList();

      setState(() {
        classList = classes;
        isLoadingClasses = false;
      });
    } catch (e) {
      setState(() {
        isLoadingClasses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
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

    setState(() {
      isSaving = true;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final attendanceCollection = FirebaseFirestore.instance
          .collection('attendance')
          .doc(selectedClass)
          .collection(dateStr);

      attendanceMap.forEach((studentId, present) {
        final docRef = attendanceCollection.doc(studentId);
        batch.set(docRef, {
          'present': present,
          'studentId': studentId,
          'class': selectedClass,
          'medium': selectedMedium,
          'date': dateStr,
        });
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully!')),
      );

      setState(() {
        attendanceMap.clear();
        selectedClass = null;
        selectedMedium = null;
        classList.clear();
        isSaving = false;
      });
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving attendance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Attendance',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Medium", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMedium,
                      isExpanded: true,
                      hint: Text("Select Medium", style: GoogleFonts.alatsi(fontSize: 16)),
                      items: mediumList.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: GoogleFonts.alatsi(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMedium = value;
                          selectedClass = null;
                          classList = [];
                          attendanceMap.clear();
                        });
                        if (value != null) {
                          fetchClassesByMedium(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text('Class', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              isLoadingClasses
                  ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
                  : Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Class',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedClass,
                    items: classList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedClass = v;
                        attendanceMap.clear();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text('Select Date', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                      hintText: 'Select Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Student List
              if (selectedMedium != null && selectedClass != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .where('Medium', isEqualTo: selectedMedium)
                      .where('className', isEqualTo: selectedClass)
                      .orderBy('Student Name') // Use correct field name here
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No students found.'));

                    final students = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: students.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final studentDoc = students[index];
                        final data = studentDoc.data() as Map<String, dynamic>;

                        final studentName = data['Student Name'] ?? 'Unknown';
                        final studentId = studentDoc.id;
                        final isPresent = attendanceMap[studentId];

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(studentName,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => attendanceMap[studentId] = true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isPresent == true ? Colors.black : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 28),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => setState(() => attendanceMap[studentId] = false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isPresent == false ? Colors.black : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Attendance",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
