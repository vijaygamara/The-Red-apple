import 'package:flutter/material.dart';
import 'package:the_red_apple/Event_Dateil_Screen/event_detail.dart';

class EventPhoto extends StatefulWidget {
  const EventPhoto({super.key});

  @override
  State<EventPhoto> createState() => _EventPhotoState();
}

class _EventPhotoState extends State<EventPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Photos'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          'No images selected',
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventDetail()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
