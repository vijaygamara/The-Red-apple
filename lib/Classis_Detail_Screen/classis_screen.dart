import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:the_red_apple/Classis/classis.dart';

class ClassisScreen extends StatefulWidget {
  const ClassisScreen({super.key});

  @override
  State<ClassisScreen> createState() => _ClassisScreenState();
}

class _ClassisScreenState extends State<ClassisScreen> {
  final databaseRef = FirebaseDatabase.instance.ref('classes');

  void deleteClass(String key) {
    databaseRef.child(key).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class deleted successfully')),
    );
  }

  void showEditDialog(String key, Map data) {
    final TextEditingController classController = TextEditingController(text: data['className']);
    TimeOfDay? selectedTime = _parseTime(data['time']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Class'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Text(selectedTime == null
                      ? 'Pick Time'
                      : 'Selected: ${selectedTime!.format(context)}'),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                databaseRef.child(key).update({
                  'className': classController.text,
                  'time': (selectedTime ?? TimeOfDay.now()).format(context),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Class Time Table",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map;
            List items = map.entries.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var key = items[index].key;
                var data = items[index].value;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      "Class: ${data['className']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Time: ${data['time']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showEditDialog(key, data);
                        } else if (value == 'delete') {
                          deleteClass(key);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("No Data Found"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Classis()),
          );
          if (result == 'saved') {
            setState(() {});
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
