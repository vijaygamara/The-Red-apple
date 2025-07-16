import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Studentview extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const Studentview({super.key, required this.studentData});

  @override
  State<Studentview> createState() => _StudentviewState();
}

class _StudentviewState extends State<Studentview> {
  @override
  Widget build(BuildContext context) {
    final String? phoneNumber = widget.studentData['Mobile Number'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details',style: TextStyle(fontSize: 25,
        fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailCard(Icons.person, "Name", widget.studentData['Student Name']),
            _buildDetailCard(Icons.school, "Class", widget.studentData['Class Name']),
            _buildDetailCard(Icons.language_rounded, "Medium", widget.studentData['Medium']),
            _buildDetailCard(Icons.people, "Parent Name", widget.studentData['Parents Name']),
            _buildDetailCard(Icons.home, "Address", widget.studentData['Address']),
            _buildDetailCard(Icons.phone, "Mobile Number", phoneNumber, isPhoneNumber: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String? value, {bool isPhoneNumber = false}) {
    return InkWell(
      onTap: isPhoneNumber && value != null && value.trim().isNotEmpty
          ? () async {
        final Uri uri = Uri(scheme: 'tel', path: value.trim());
        print("Trying to launch dialer: ${uri.toString()}");

        try {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch dialer')),
            );
          }
        } catch (e) {
          print("Error: $e");
        }
      }
          : null,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: Icon(icon, color: Colors.red.shade400),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            value ?? 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isPhoneNumber ? Colors.blue : Colors.black,
              decoration: isPhoneNumber ? TextDecoration.underline : null,
            ),
          ),
          trailing: isPhoneNumber
              ? Icon(Icons.call, color: Colors.green.shade600)
              : null,
        ),
      ),
    );
  }
}
