import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> resultList = [];

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  void fetchResults() async {
    final snapshot = await FirebaseFirestore.instance.collection('student_results').get();

    setState(() {
      resultList = snapshot.docs.map((doc) => doc.data()).cast<Map<String, dynamic>>().toList();
    });
  }

  String calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'F';
  }

  Color getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.redAccent;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Student Results"),
        backgroundColor: Colors.deepPurple,
      ),
      body: resultList.isEmpty
          ? const Center(child: Text("No results found", style: TextStyle(fontSize: 16)))
          : ListView.builder(
        itemCount: resultList.length,
        itemBuilder: (context, index) {
          final result = resultList[index];
          final studentName = result['studentName'] ?? 'No Name';
          final className = result['className'] ?? 'N/A';
          final subject = result['subjectName'] ?? 'N/A';
          final totalMarks = result['totalMarks'] ?? 0;
          final obtainedMarks = result['obtainedMarks'] ?? 0;
          final percentage = totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;
          final grade = calculateGrade(percentage);
          final gradeColor = getGradeColor(grade);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(studentName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Chip(
                      label: Text(grade,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: gradeColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildInfoChip(Icons.class_, "Class: $className"),
                    _buildInfoChip(Icons.book, "Subject: $subject"),
                    _buildInfoChip(Icons.score, "Marks: $obtainedMarks/$totalMarks"),
                    _buildInfoChip(Icons.percent, "Percentage: ${percentage.toStringAsFixed(2)}%"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurple),
      label: Text(label),
      backgroundColor: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
