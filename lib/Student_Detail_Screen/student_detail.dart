import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDetail extends StatefulWidget {
  final Map<String, dynamic>? studentData;
  final String? docId;

  const StudentDetail({super.key, this.studentData, this.docId});

  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  final TextEditingController namecontroller = TextEditingController();
  // final TextEditingController mediumcontroller = TextEditingController();
  final TextEditingController pnamecontroller = TextEditingController();
  final TextEditingController addresscontroller = TextEditingController();
  final TextEditingController phonecontroller = TextEditingController();

  String? selectedClass;
  List<Map<String, String>> classTeacherList = [];
  List<String> medium = ['English Medium','Gujarati Medium'];
  String? selectedMedium;
  bool isLoadingClasses = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchClasses().then((_) {
      if (widget.studentData != null) {
        prefillData(widget.studentData!);
      }
    });
  }

  Future<void> fetchClasses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('classes').get();
      List<Map<String, String>> tempList = [];
      Set<String> seenClasses = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final className = data['className'] ?? '';

        if (className.isNotEmpty && !seenClasses.contains(className)) {
          tempList.add({
            'className': className,
          });
          seenClasses.add(className);
        }
      }

      setState(() {
        classTeacherList = tempList;
        isLoadingClasses = false;
      });
    } catch (e) {
      debugPrint("Error fetching classes: $e");
      setState(() {
        isLoadingClasses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching classes: $e")),
      );
    }
  }

  void prefillData(Map<String, dynamic> data) {
    namecontroller.text = data['Student Name'] ?? '';
    selectedMedium = data['Medium'] ?? '';
    pnamecontroller.text = data['Parents Name'] ?? '';
    addresscontroller.text = data['Address'] ?? '';
    phonecontroller.text = data['Mobile Number'] ?? '';
    selectedClass = data['Class Name'];
  }

  void saveOrUpdateData() async {
    if (namecontroller.text.isEmpty ||
        selectedClass == null ||
        selectedMedium == 'Medium' ||
        pnamecontroller.text.isEmpty ||
        addresscontroller.text.isEmpty ||
        phonecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final data = {
      'Student Name': namecontroller.text,
      'Class Name': selectedClass,
      'Medium': selectedMedium,
      'Parents Name': pnamecontroller.text,
      'Address': addresscontroller.text,
      'Mobile Number': phonecontroller.text,
      'time': FieldValue.serverTimestamp(),
      'localTime': DateTime.now().millisecondsSinceEpoch,
    };

    setState(() {
      isUpdating = true;
    });

    try {
      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.docId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('students').add(data);
      }
      if (mounted) Navigator.pop(context, data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.docId != null ? "Edit Student" : "Add Student",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoadingClasses
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildField("Student Name", namecontroller, "Enter Student Name"),
                const SizedBox(height: 15),
                Text("Class Name", style: GoogleFonts.alatsi(fontSize: 19)),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: classTeacherList.any((item) => item['className'] == selectedClass)
                            ? selectedClass
                            : null,
                        isExpanded: true,
                        hint: Text("Select Class Name", style: GoogleFonts.alatsi(fontSize: 16)),
                        items: classTeacherList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['className'],
                            child: Text(item['className'] ?? '', style: GoogleFonts.alatsi(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                            // Removed assignedTeacher logic
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                // Inside build method widget list:
                Text("Medium", style: GoogleFonts.alatsi(fontSize: 19)),
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
                        items: medium.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item, style: GoogleFonts.alatsi(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMedium = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                buildField("Parent's Name", pnamecontroller, "Enter Parent's Name"),
                const SizedBox(height: 15),
                buildField("Address", addresscontroller, "Enter Address", maxLines: 4),
                const SizedBox(height: 15),
                buildField("Mobile Number", phonecontroller, "Enter Phone Number",
                    inputType: TextInputType.number),
                const SizedBox(height: 100),
                Center(
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : saveOrUpdateData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      widget.docId != null ? 'Update Details' : 'Save Details',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.alatsi(fontSize: 19)),
        const SizedBox(height: 5),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: controller,
              keyboardType: inputType,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
