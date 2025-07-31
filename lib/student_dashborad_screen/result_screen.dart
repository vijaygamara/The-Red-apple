import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ResultScreen({super.key, required this.studentData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final studentClass = widget.studentData['Class Name'];
    final studentMedium = widget.studentData['Medium'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Results'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('results')
            .where('Class', isEqualTo: studentClass)
            .where('Medium', isEqualTo: studentMedium)
            .orderBy('Timestamp', descending: true) // updated field name
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No results available'));
          }

          final result = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: result.length,
            itemBuilder: (context, index) {
              final data = result[index].data() as Map<String, dynamic>;
              final timestamp = data['Timestamp'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              final imageList = List<String>.from(data['Images'] ?? []);
              final note = data['Text'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date: ${date.day}-${date.month}-${date.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (note.isNotEmpty)
                        Text("Note: $note"),
                      if (imageList.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageList.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageList[i],
                                  width: 120,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
