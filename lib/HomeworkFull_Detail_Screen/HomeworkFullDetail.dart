import 'package:flutter/material.dart';

class HomeworkFullDetail extends StatefulWidget {
  final Map<String, dynamic> data;

  const HomeworkFullDetail({super.key, required this.data});

  @override
  State<HomeworkFullDetail> createState() => _HomeworkFullDetailState();
}

class _HomeworkFullDetailState extends State<HomeworkFullDetail> {
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.red,
              title: const Text("Preview"),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(widget.data['date'] ?? '') ?? DateTime.now();
    final images = widget.data['images'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Details',style: TextStyle(
          fontSize: 25,fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                Chip(
                  label: Text(
                    'Class: ${widget.data['class'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    "Date: ${date.day}-${date.month}-${date.year}",
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (widget.data['text'] != null && widget.data['text'].toString().isNotEmpty) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Homework",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.data['text'],
                        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            if (images.isNotEmpty) ...[
              const Text(
                "Attached Images",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, i) {
                  String url = images[i];
                  return GestureDetector(
                    onTap: () => _showFullImage(url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
