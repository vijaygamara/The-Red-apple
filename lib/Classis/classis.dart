import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Classis extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const Classis({super.key, this.docId, this.existingData});

  @override
  State<Classis> createState() => _ClassisState();
}

class _ClassisState extends State<Classis> {
  final TextEditingController classcontroller = TextEditingController();
  TimeOfDay? selectedTime;
  List<String> mediumList = ['English Medium', 'Gujarati Medium'];
  String? selectedMedium;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      selectedMedium = widget.existingData!['medium'];
      classcontroller.text = widget.existingData!['className'] ?? '';
      selectedTime = _parseTime(widget.existingData!['time']);
    }
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].substring(0, 2).trim());
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void saveData() async {
    if (selectedMedium == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Medium first')),
      );
      return;
    }

    if (classcontroller.text.trim().isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    String formattedTime = selectedTime!.format(context);
    final collection = FirebaseFirestore.instance.collection('classes');

    try {
      if (widget.docId != null) {
        await collection.doc(widget.docId).update({
          'className': classcontroller.text.trim(),
          'time': formattedTime,
          'medium': selectedMedium,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await collection.add({
          'className': classcontroller.text.trim(),
          'time': formattedTime,
          'medium': selectedMedium,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) Navigator.pop(context, 'saved');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    classcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isClassEnabled = selectedMedium != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.docId == null ? "Add Class" : "Edit Class",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Medium", style: GoogleFonts.alatsi(fontSize: 19)),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMedium,
                        isExpanded: true,
                        hint: Text("Select Medium",
                            style: GoogleFonts.alatsi(fontSize: 16)),
                        items: mediumList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child:
                            Text(item, style: GoogleFonts.alatsi(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMedium = value;
                            // Clear class text when medium changes
                            classcontroller.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text("Class", style: GoogleFonts.alatsi(fontSize: 19)),
                const SizedBox(height: 8),

                // Class TextField disabled until Medium selected
                TextField(
                  enabled: isClassEnabled,
                  controller: classcontroller,
                  decoration: InputDecoration(
                    hintText: isClassEnabled
                        ? 'Enter Class Name'
                        : 'Select Medium First',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    // greyed out if disabled
                    filled: !isClassEnabled,
                    fillColor: isClassEnabled ? Colors.white : Colors.grey.shade200,
                  ),
                ),

                const SizedBox(height: 20),

                Text('Select Time', style: GoogleFonts.alatsi(fontSize: 20)),
                const SizedBox(height: 8),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          selectedTime == null
                              ? 'No Time Selected'
                              : 'Selected Time: ${selectedTime!.format(context)}',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => selectTime(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Pick a Time'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      widget.docId == null ? 'Save Details' : 'Update Details',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

