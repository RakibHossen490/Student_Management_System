import 'package:flutter/material.dart';
import 'attendance/attendance_student_screen.dart';

class AttendanceSemesterScreen extends StatelessWidget {
  final String department;

  const AttendanceSemesterScreen({Key? key, required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$department - Semesters")),
      body: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          final sem = (index + 1).toString();
          return ListTile(
            leading: Icon(Icons.calendar_month),
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
          );
        },
      ),
    );
  }
}