import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class Classis extends StatefulWidget {
  const Classis({super.key});

  @override
  State<Classis> createState() => _ClassisState();
}

class _ClassisState extends State<Classis> {
  final TextEditingController classcontroller = TextEditingController();
  TimeOfDay? selectedTime;
  final databaseRef = FirebaseDatabase.instance.ref('classes');

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
    if (classcontroller.text.isNotEmpty && selectedTime != null) {
      String formattedTime = selectedTime!.format(context);
      await databaseRef.push().set({
        'className': classcontroller.text,
        'time': formattedTime,
      });
      Navigator.pop(context, 'saved');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Class Details")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Class", style: GoogleFonts.alatsi(fontSize: 19)),
                const SizedBox(height: 8),
                TextField(
                  controller: classcontroller,
                  decoration: InputDecoration(
                    hintText: 'Enter Class Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      children: [
                        Text(
                          selectedTime == null
                              ? 'No Time Selected'
                              : 'Selected Time: ${selectedTime!.format(context)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => selectTime(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const SizedBox(height: 350),
                Center(
                  child: ElevatedButton(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Save Details',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
