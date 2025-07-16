import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_red_apple/Home_Work_Screen/homework.dart';
import 'package:the_red_apple/HomeworkFull_Detail_Screen/HomeworkFullDetail.dart';
import '../utils/image_utils.dart';

class Homeworkdetail extends StatefulWidget {
  const Homeworkdetail({super.key});

  @override
  State<Homeworkdetail> createState() => _HomeworkdetailState();
}

class _HomeworkdetailState extends State<Homeworkdetail> {
  void deletehomework(String docId, List<dynamic>? images) async {
    try {
      if (images != null && images.isNotEmpty) {
        for (String imageUrl in images) {
          try {
            await ImageUtils.deleteImageFromFirebase(imageUrl);
          } catch (e) {
            print('Failed to delete image: $e');
          }
        }
      }

      await FirebaseFirestore.instance.collection('homework').doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Homework Deleted Successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete homework: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void openEditScreen(String docId, Map<String, dynamic> homework) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Homework(homeworkData: homework, docId: docId)),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Homework Image'),
              backgroundColor: Colors.red,
              automaticallyImplyLeading: false,
              actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Failed to load image'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final redTheme = Colors.red.shade400;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Detail', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('homework').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No homework added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              final date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();

              return Dismissible(
                key: Key(id),
                background: Container(
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  color: Colors.blue,
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    openEditScreen(id, data);
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text("Are you sure you want to delete this homework?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          )
                        ],
                      ),
                    );
                    return confirm == true;
                  }
                  return false;
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    deletehomework(id, data['images']);
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeworkFullDetail(data: data,)));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Class: ${data['class'] ?? 'No Class'}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Date: ${date.day}-${date.month}-${date.year}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                if (data['text'] != null && data['text'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text("Homework: ${data['text']}"),
                                ],
                                if (data['images'] != null && (data['images'] as List).isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 90,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (data['images'] as List).length,
                                      itemBuilder: (context, i) {
                                        String imageUrl = data['images'][i];
                                        return GestureDetector(
                                          onTap: () => _showFullImage(context, imageUrl),
                                          child: Container(
                                            width: 90,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.error_outline, color: Colors.grey),
                                                ),
                                              ),
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
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Homework()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Homework'),
      ),
    );
  }
}
