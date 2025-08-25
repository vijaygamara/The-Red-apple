import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Note_Screen/note_screen.dart';

class NoteViewScreen extends StatefulWidget {
  const NoteViewScreen({super.key});

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  String? selectedMedium;
  String? selectedClass;
  List<String> mediumList = ['English Medium', 'Gujarati Medium'];
  List<String> classList = [];
  bool isLoadingClasses = false;

  Future<void> fetchClassesByMedium(String medium) async {
    setState(() {
      isLoadingClasses = true;
      selectedClass = null;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('medium', isEqualTo: medium)
        .get();

    final classes = snapshot.docs.map((doc) => doc['className'] as String).toList();

    setState(() {
      classList = classes;
      isLoadingClasses = false;
    });
  }

  Future<void> _deleteNote(String noteId) async {
    await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<QuerySnapshot> _buildNotesStream() {
    Query query = FirebaseFirestore.instance.collection('notes').orderBy('createdAt', descending: true);

    if (selectedMedium != null) query = query.where('medium', isEqualTo: selectedMedium);
    if (selectedClass != null) query = query.where('class', isEqualTo: selectedClass);

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        title: Text("View Notes", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMedium,
                  decoration: const InputDecoration(labelText: "Medium", border: OutlineInputBorder()),
                  items: [null, ...mediumList].map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m ?? "All Mediums"),
                    );
                  }).toList(),
                  onChanged: (v) async {
                    setState(() {
                      selectedMedium = v;
                      selectedClass = null;
                      classList.clear();
                    });
                    if (v != null) await fetchClassesByMedium(v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(labelText: "Class", border: OutlineInputBorder()),
                  items: [null, ...classList].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c ?? "All Classes"));
                  }).toList(),
                  onChanged: (v) => setState(() => selectedClass = v),
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildNotesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final notes = snapshot.data!.docs;

                if (notes.isEmpty) {
                  return const Center(child: Text("No Notes Found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final note = notes[i].data() as Map<String, dynamic>;
                    final id = notes[i].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(note['title'] ?? "No Title"),
                        subtitle: Text(note['content'] ?? "No Content", maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == "edit") {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => NoteScreen(noteData: note, docId: id),
                              ));
                            } else if (v == "delete") {
                              _deleteNote(id);
                            }
                          },
                          itemBuilder: (c) => [
                            const PopupMenuItem(value: "edit", child: Text("Edit")),
                            const PopupMenuItem(value: "delete", child: Text("Delete")),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
