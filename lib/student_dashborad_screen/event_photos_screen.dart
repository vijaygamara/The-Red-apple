import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventPhotosScreen extends StatelessWidget {
  const EventPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'Event Gallery',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No event photos available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final doc = events[index];
              final data = doc.data() as Map<String, dynamic>;
              final images = List<String>.from(data['images'] ?? []);
              final description = data['description'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      images.isEmpty
                          ? const Text(
                        "No images available",
                        style: TextStyle(color: Colors.grey),
                      )
                          : SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                          itemBuilder: (context, imgIndex) {
                            final imageUrl = images[imgIndex];
                            final tag = 'img-$index-$imgIndex';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImageViewer(
                                      imageUrl: imageUrl,
                                      tag: tag,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: tag,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: 160,
                                    height: 140,
                                    fit: BoxFit.cover,
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
            },
          );
        },
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

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
            ),
          ],
        ),
      ),
    );
  }
}
