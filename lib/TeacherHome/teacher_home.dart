import 'package:flutter/material.dart';

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Home')),
      body: const Center(child: Text('Welcome Teacher!')),
    );
  }
}
