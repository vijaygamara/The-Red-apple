import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'Result',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('results')
            .where('Class', isEqualTo: studentClass)
            .where('Medium', isEqualTo: studentMedium)
            .orderBy('Timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No results available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final results = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final data = results[index].data() as Map<String, dynamic>;
              final timestamp = data['Timestamp'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              final formattedDate = DateFormat('dd MMM yyyy').format(date);

              final imageList = List<String>.from(data['Images'] ?? []);
              final note = data['Text'] ?? '-';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultDetailScreen(resultData: data),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCAF0F8), Color(0xFFE0FBFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: $formattedDate',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (note.isNotEmpty)
                          Text(
                            'Note: $note',
                            style: const TextStyle(
                              fontSize: 16.5,
                              color: Colors.black87,
                            ),
                          ),
                        if (imageList.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageList.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final imageUrl = imageList[i];
                                // **No GestureDetector or Hero here, so no fullscreen open**
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    imageUrl,
                                    width: 140,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        width: 140,
                                        height: 160,
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 140,
                                        height: 160,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
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

class ResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultDetailScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final note = resultData['Text'] ?? '';
    final timestamp = resultData['Timestamp'];
    final imageList = List<String>.from(resultData['Images'] ?? []);
    final formattedDate = timestamp != null
        ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
        : 'Unknown';

    final medium = resultData['Medium'] ?? 'Medium';
    final className = resultData['Class'] ?? 'Class';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'Result Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medium + Class + Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Medium and Class Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.blue, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          '$medium Medium',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.class_, color: Colors.grey, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          className,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),

                // Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Result Note Section Title
            Row(
              children: const [
                Text('📝', style: TextStyle(fontSize: 22)),
                SizedBox(width: 6),
                Text(
                  "Result Note:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Result Note Container (pink background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                note.isNotEmpty ? note : '-',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Result Images Section Title
            Row(
              children: const [
                Text('🖼', style: TextStyle(fontSize: 22)),
                SizedBox(width: 6),
                Text(
                  "Result Images:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Images horizontal list with fullscreen on tap
            if (imageList.isEmpty)
              const Text(
                "No images available.",
                style: TextStyle(color: Colors.grey),
              )
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageUrl = imageList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              imageUrl: imageUrl,
                              tag: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: imageUrl,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            imageUrl,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 140,
                                height: 140,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.redAccent),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 140,
                                height: 140,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImageViewer({super.key, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: tag,
                child: InteractiveViewer(
                  child: Image.network(imageUrl),
                ),
              ),
            ),
            const Positioned(
              top: 40,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: BackButton(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
