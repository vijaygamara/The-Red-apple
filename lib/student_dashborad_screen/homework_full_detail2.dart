import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeworkFullDetail2 extends StatefulWidget {
  final Map<String, dynamic> data;

  const HomeworkFullDetail2({super.key, required this.data});

  @override
  State<HomeworkFullDetail2> createState() => _HomeworkFullDetail2State();
}

class _HomeworkFullDetail2State extends State<HomeworkFullDetail2> {
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(widget.data['date'] ?? '') ?? DateTime.now();
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

    final images = widget.data['images'] as List<dynamic>? ?? [];
    final note = widget.data['text'] ?? '-';
    final medium = widget.data['medium'] ?? 'Medium';
    final className = widget.data['class'] ?? 'Class';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'Homework Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medium + Class + Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Medium and Class
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Colors.blue, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            '$medium',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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

              // Homework Text Section Title
              Row(
                children: const [
                  Text('📘', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Text(
                    "Homework Text:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Homework Text Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  note.toString().isNotEmpty ? note : '-',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Homework Images Section Title
              Row(
                children: const [
                  Text('🖼', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Text(
                    "Homework Images:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (images.isEmpty)
                const Text("No images available.", style: TextStyle(color: Colors.grey))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final imageUrl = images[index].toString();
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullscreenImage(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: Hero(
                        tag: imageUrl, // unique tag for Hero animation
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.redAccent),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenImage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 60, color: Colors.white54);
              },
            ),
          ),
        ),
      ),
    );
  }
}
