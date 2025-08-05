import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String className;
  final String medium;
  final String mobileNumber;

  const StudentAttendanceScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.medium,
    required this.mobileNumber,
  });

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, bool> _attendanceMap = {};
  bool isLoading = false;
  int totalDays = 0;
  int presentDays = 0;
  int absentDays = 0;
  double attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // First, get the student's document ID using mobile number
      final studentQuery = await FirebaseFirestore.instance
          .collection('students')
          .where('Mobile Number', isEqualTo: widget.mobileNumber)
          .get();

      if (studentQuery.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final studentDocId = studentQuery.docs.first.id;
      
      // Get the class document ID
      final classQuery = await FirebaseFirestore.instance
          .collection('classes')
          .where('className', isEqualTo: widget.className)
          .where('medium', isEqualTo: widget.medium)
          .get();

      if (classQuery.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final classId = classQuery.docs.first.id;
      
      // Get all attendance records for this class
      final attendanceQuery = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(classId)
          .collection('dates')
          .get();

      final Map<DateTime, bool> attendanceData = {};
      int present = 0;
      int absent = 0;

      for (var doc in attendanceQuery.docs) {
        final data = doc.data();
        final students = data['students'] as Map<String, dynamic>? ?? {};
        
        print('=== Checking attendance record ===');
        print('Date: ${data['date']}');
        print('Available student keys: ${students.keys.toList()}');
        print('Looking for student ID: $studentDocId');
        print('Student Mobile: ${widget.mobileNumber}');
        print('Student Name: ${widget.studentName}');
        
        // Try multiple ways to match the student
        bool found = false;
        bool isPresent = false;
        
        // Method 1: Direct document ID match
        if (students.containsKey(studentDocId)) {
          isPresent = students[studentDocId] ?? false;
          found = true;
          print('✅ Found by document ID: ${data['date']} - ${isPresent ? 'Present' : 'Absent'}');
        }
        
        // Method 2: Try matching by mobile number as key
        if (!found && students.containsKey(widget.mobileNumber)) {
          isPresent = students[widget.mobileNumber] ?? false;
          found = true;
          print('✅ Found by mobile number: ${data['date']} - ${isPresent ? 'Present' : 'Absent'}');
        }
        
        // Method 3: Try matching by student name
        if (!found) {
          for (String key in students.keys) {
            print('Checking key: "$key" against name: "${widget.studentName}"');
            if (key.toLowerCase().contains(widget.studentName.toLowerCase()) || 
                widget.studentName.toLowerCase().contains(key.toLowerCase())) {
              isPresent = students[key] ?? false;
              found = true;
              print('✅ Found by name match: ${data['date']} - ${isPresent ? 'Present' : 'Absent'}');
              break;
            }
          }
        }
        
        // Method 4: Try partial name matching
        if (!found) {
          for (String key in students.keys) {
            final studentNameWords = widget.studentName.toLowerCase().split(' ');
            final keyWords = key.toLowerCase().split(' ');
            
            bool nameMatch = false;
            for (String word in studentNameWords) {
              if (word.length > 2 && key.toLowerCase().contains(word)) {
                nameMatch = true;
                break;
              }
            }
            
            if (nameMatch) {
              isPresent = students[key] ?? false;
              found = true;
              print('✅ Found by partial name match: ${data['date']} - ${isPresent ? 'Present' : 'Absent'}');
              break;
            }
          }
        }
        
        if (found) {
          final date = DateTime.parse(data['date']);
          attendanceData[DateTime(date.year, date.month, date.day)] = isPresent;
          
          if (isPresent) {
            present++;
          } else {
            absent++;
          }
        } else {
          print('❌ Student not found in attendance record for ${data['date']}');
          print('Available keys: ${students.keys.toList()}');
        }
        print('=== End checking ===\n');
      }

      setState(() {
        _attendanceMap = attendanceData;
        presentDays = present;
        absentDays = absent;
        totalDays = present + absent;
        attendancePercentage = totalDays > 0 ? (present / totalDays) * 100 : 0.0;
        isLoading = false;
      });
      
      // Force refresh the calendar
      setState(() {});
      
      if (totalDays == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No attendance records found for this student. Please check if attendance was uploaded correctly.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Debug information
      print('Student Mobile: ${widget.mobileNumber}');
      print('Student Doc ID: $studentDocId');
      print('Class ID: $classId');
      print('Total attendance records found: ${attendanceQuery.docs.length}');
      print('Attendance data: $_attendanceMap');
      
      // Show attendance map contents
      print('=== ATTENDANCE MAP CONTENTS ===');
      _attendanceMap.forEach((date, isPresent) {
        print('${date.day}/${date.month}/${date.year}: ${isPresent ? 'Present' : 'Absent'}');
      });
      print('=== END ATTENDANCE MAP ===');
      
      // Show all attendance records for debugging
      for (var doc in attendanceQuery.docs) {
        final data = doc.data();
        print('=== Attendance Record ===');
        print('Date: ${data['date']}');
        print('Class: ${data['class_name']}');
        print('Medium: ${data['medium']}');
        print('Students: ${data['students']}');
        print('=======================');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
    }
  }

  void _addTestData() {
    setState(() {
      // Add some test data for current month
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      
      // Add test data for first 10 days of current month
      for (int i = 1; i <= 10; i++) {
        final day = DateTime(now.year, now.month, i);
        if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
          _attendanceMap[day] = i % 2 == 0; // Alternate present/absent
        }
      }
      
      // Calculate statistics
      int present = 0, absent = 0;
      _attendanceMap.forEach((date, isPresent) {
        if (isPresent) present++; else absent++;
      });
      
      presentDays = present;
      absentDays = absent;
      totalDays = present + absent;
      attendancePercentage = totalDays > 0 ? (present / totalDays) * 100 : 0.0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test data added for ${DateFormat('MMMM yyyy').format(DateTime.now())}')),
    );
  }

  Future<void> _checkFirestoreData() async {
    try {
      // Get the class document ID
      final classQuery = await FirebaseFirestore.instance
          .collection('classes')
          .where('className', isEqualTo: widget.className)
          .where('medium', isEqualTo: widget.medium)
          .get();

      if (classQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class not found')),
        );
        return;
      }

      final classId = classQuery.docs.first.id;
      
      // Get all attendance records for this class
      final attendanceQuery = await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(classId)
          .collection('dates')
          .get();

      print('=== FIRESTORE DATA CHECK ===');
      print('Class ID: $classId');
      print('Total attendance records: ${attendanceQuery.docs.length}');
      
      for (var doc in attendanceQuery.docs) {
        final data = doc.data();
        print('\n--- Attendance Record ---');
        print('Document ID: ${doc.id}');
        print('Date: ${data['date']}');
        print('Class: ${data['class_name']}');
        print('Medium: ${data['medium']}');
        print('Students: ${data['students']}');
        print('Student keys: ${(data['students'] as Map<String, dynamic>).keys.toList()}');
        print('--- End Record ---');
      }
      print('=== END FIRESTORE CHECK ===');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found ${attendanceQuery.docs.length} attendance records. Check console for details.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking data: $e')),
      );
    }
  }

  bool _isPresent(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final isPresent = _attendanceMap[normalizedDay] ?? false;
    return isPresent;
  }

  bool _isAbsent(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final attendance = _attendanceMap[normalizedDay];
    final isAbsent = attendance != null && !attendance;
    return isAbsent;
  }

  bool _hasAttendance(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final hasAttendance = _attendanceMap.containsKey(normalizedDay);
    return hasAttendance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF00B4D8),
        title: Text(
          'My Attendance',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAttendanceData,
          ),
        ],
      ),
             body: SafeArea(
         child: isLoading
             ? const Center(
                 child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
               )
                                                                                                 : ListView(
                 padding: const EdgeInsets.only(
                   left: 25, // Increased side padding
                   right: 25, // Increased side padding
                   top: 20,
                   bottom: 150, // Much more padding for bottom navigation
                 ),
                children: [
                                     // Student Info Card
                   Container(
                     margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
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
                       child: Row(
                         children: [
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   widget.studentName,
                                   style: GoogleFonts.poppins(
                                     fontSize: 20, // smaller font size
                                     fontWeight: FontWeight.w600,
                                     color: Colors.black,
                                   ),
                                 ),
                                 const SizedBox(height: 4),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     // Medium with Icon (Left side)
                                     Row(
                                       children: [
                                         const Icon(
                                           Icons.school,
                                           size: 20,
                                           color: Color(0xFF0077B6),
                                         ),
                                         const SizedBox(width: 6),
                                         Text(
                                           widget.medium,
                                           style: GoogleFonts.poppins(
                                             fontSize: 18,
                                             color: Colors.black,
                                             fontWeight: FontWeight.w500,
                                           ),
                                         ),
                                       ],
                                     ),

                                     // Class (Right side)
                                     Text(
                                       widget.className,
                                       style: GoogleFonts.poppins(
                                         fontSize: 14,
                                         color: Color(0xFF0077B6),
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                   ],
                                 ),

                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                  ),

                                     // Attendance Statistics
                   Container(
                     margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
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
                        children: [
                          Text(
                            'Attendance Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF023E8A),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Total Days',
                                totalDays.toString(),
                                const Color(0xFF0077B6),
                                Icons.calendar_today,
                              ),
                              _buildStatCard(
                                'Present',
                                presentDays.toString(),
                                const Color(0xFF2E8B57),
                                Icons.check_circle,
                              ),
                              _buildStatCard(
                                'Absent',
                                absentDays.toString(),
                                const Color(0xFFDC143C),
                                Icons.cancel,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: attendancePercentage >= 75 
                                  ? const Color(0xFF2E8B57)
                                  : attendancePercentage >= 60 
                                      ? const Color(0xFFFF8C00)
                                      : const Color(0xFFDC143C),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Attendance: ${attendancePercentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                                     // Calendar
                   Container(
                     margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Attendance Calendar',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF023E8A),
                            ),
                          ),
                          const SizedBox(height: 16),
                                                     SizedBox(
                            height: 400, // Fixed height to show full month
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.now(),
                              focusedDay: _focusedDay,
                              calendarFormat: CalendarFormat.month, // Force month format
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                             calendarStyle: const CalendarStyle(
                               outsideDaysVisible: false,
                               weekendTextStyle: TextStyle(color: Color(0xFF666666)),
                               defaultTextStyle: TextStyle(color: Color(0xFF333333)),
                               selectedTextStyle: TextStyle(color: Colors.white),
                               todayTextStyle: TextStyle(color: Colors.white),
                               cellMargin: EdgeInsets.all(1),
                               cellPadding: EdgeInsets.all(0),
                             ),
                                                           headerStyle: const HeaderStyle(
                                titleTextStyle: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                formatButtonVisible: false,
                                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF333333)),
                                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF333333)),
                              ),
                             calendarBuilders: CalendarBuilders(
                                                               defaultBuilder: (context, day, focusedDay) {
                                  // Check if it's a weekend (Saturday = 6, Sunday = 7)
                                  final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                                  final hasAttendance = _hasAttendance(day);
                                  final isPresent = _isPresent(day);
                                  final isAbsent = _isAbsent(day);

                                  Color backgroundColor;
                                  Color borderColor;
                                  Color textColor;

                                  if (isPresent) {
                                    backgroundColor = const Color(0xFF4CAF50); // Green for present
                                    borderColor = const Color(0xFF4CAF50);
                                    textColor = Colors.white;
                                  } else if (isAbsent) {
                                    backgroundColor = const Color(0xFFF44336); // Red for absent
                                    borderColor = const Color(0xFFF44336);
                                    textColor = Colors.white;
                                  } else if (isWeekend) {
                                    backgroundColor = Colors.grey[100]!; // Light grey for weekends
                                    borderColor = const Color(0xFFE0E0E0);
                                    textColor = const Color(0xFF666666);
                                  } else {
                                    backgroundColor = Colors.white; // White for normal days
                                    borderColor = const Color(0xFFE0E0E0);
                                    textColor = const Color(0xFF333333);
                                  }

                                  return Container(
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: hasAttendance ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                               selectedBuilder: (context, day, focusedDay) {
                                 return Container(
                                   margin: const EdgeInsets.all(1),
                                   decoration: BoxDecoration(
                                     color: const Color(0xFF2196F3),
                                     borderRadius: BorderRadius.circular(4),
                                     border: Border.all(
                                       color: const Color(0xFF2196F3),
                                       width: 2,
                                     ),
                                   ),
                                   child: Center(
                                     child: Text(
                                       '${day.day}',
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold,
                                         fontSize: 14,
                                       ),
                                     ),
                                   ),
                                 );
                               },
                               todayBuilder: (context, day, focusedDay) {
                                 return Container(
                                   margin: const EdgeInsets.all(1),
                                   decoration: BoxDecoration(
                                     color: _isPresent(day)
                                         ? const Color(0xFF4CAF50)
                                         : _isAbsent(day)
                                             ? const Color(0xFFF44336)
                                             : const Color(0xFF2196F3),
                                     borderRadius: BorderRadius.circular(4),
                                     border: Border.all(
                                       color: _isPresent(day)
                                           ? const Color(0xFF4CAF50)
                                           : _isAbsent(day)
                                               ? const Color(0xFFF44336)
                                               : const Color(0xFF2196F3),
                                       width: 2,
                                     ),
                                   ),
                                   child: Center(
                                     child: Text(
                                       '${day.day}',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold,
                                         fontSize: 14,
                                       ),
                                     ),
                                   ),
                                 );
                               },
                               outsideBuilder: (context, day, focusedDay) => const SizedBox.shrink(),
                             ),
                           ),
                                                     )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                                     // Legend
                   Container(
                     margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
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
                       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                       child: Column(
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               Row(
                                 children: [
                                   Container(
                                     width: 24,
                                     height: 24,
                                     decoration: BoxDecoration(
                                       color: const Color(0xFF4CAF50),
                                       borderRadius: BorderRadius.circular(4),
                                       border: Border.all(
                                         color: const Color(0xFF4CAF50),
                                         width: 1,
                                       ),
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Text(
                                     'Present',
                                     style: GoogleFonts.poppins(
                                       fontSize: 14,
                                       fontWeight: FontWeight.w500,
                                       color: const Color(0xFF023E8A),
                                     ),
                                   ),
                                 ],
                               ),
                               Row(
                                 children: [
                                   Container(
                                     width: 24,
                                     height: 24,
                                     decoration: BoxDecoration(
                                       color: const Color(0xFFF44336),
                                       borderRadius: BorderRadius.circular(4),
                                       border: Border.all(
                                         color: const Color(0xFFF44336),
                                         width: 1,
                                       ),
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Text(
                                     'Absent',
                                     style: GoogleFonts.poppins(
                                       fontSize: 14,
                                       fontWeight: FontWeight.w500,
                                       color: const Color(0xFF023E8A),
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                  ),
                                 ],
               ),
         ),
       );
     }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF0077B6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
