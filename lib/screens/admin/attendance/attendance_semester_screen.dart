import 'package:flutter/material.dart';
import 'attendance_student_screen.dart';

class AttendanceSemesterScreen extends StatelessWidget {
  final String department;

  const AttendanceSemesterScreen({Key? key, required this.department}) : super(key: key);

  static const List<String> semesters = [
    "1","2","3","4","5","6","7","8"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$department - Semesters"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          final sem = semesters[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text("Semester $sem"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceStudentScreen(
                      department: department,
                      semester: sem,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}