import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:the_red_apple/Result_FullDetails.dart';
import 'package:the_red_apple/Result_Screen/result_screen.dart';

class ResultEntryScreen extends StatefulWidget {
  const ResultEntryScreen({super.key});

  @override
  State<ResultEntryScreen> createState() => _ResultEntryScreenState();
}

class _ResultEntryScreenState extends State<ResultEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Uploaded Results",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const ResultScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('results')
            .orderBy('Timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No results uploaded yet."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final result = snapshot.data!.docs[index];
              final data = result.data() as Map<String, dynamic>;
              final images = List<String>.from(data['Images'] ?? []);
              final date = data['Timestamp'] != null
                  ? (data['Timestamp'] as Timestamp).toDate()
                  : null;

              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResultFulldetails(resultData: data,)));
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['Medium']} - ${data['Class']}",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (date != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('dd MMM yyyy').format(date),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (data['Text'] != null && data['Text'].toString().isNotEmpty)
                          Text(
                            data['Text'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (images.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, imgIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      images[imgIndex],
                                      width: 120,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
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
