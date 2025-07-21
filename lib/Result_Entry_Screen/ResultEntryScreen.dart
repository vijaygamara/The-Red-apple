import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_red_apple/Result_Screen/result_screen.dart';

class ResultEntryScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultEntryScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uploaded Result",style: TextStyle(
            fontSize: 25,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
           Navigator.push(context,
           MaterialPageRoute(builder: (context) => ResultScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
