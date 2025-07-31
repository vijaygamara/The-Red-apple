import 'package:flutter/material.dart';

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
    final images = widget.data['images'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Detail'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date: ${date.day}-${date.month}-${date.year}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              if (widget.data['text'] != null && widget.data['text'].toString().isNotEmpty) ...[
                const Text("Homework:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(widget.data['text']),
              ],
              const SizedBox(height: 20),
              if (images.isNotEmpty) ...[
                const Text("Images:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
