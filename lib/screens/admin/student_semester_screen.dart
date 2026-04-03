import 'package:flutter/material.dart';
import 'student_list_screen.dart';

class StudentSemesterScreen extends StatelessWidget {
  final String department;

  const StudentSemesterScreen({super.key, required this.department});

  static const List<String> semesters = [
    "1", "2", "3", "4", "5", "6", "7", "8"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$department - Semesters"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          final sem = semesters[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.class_, color: Colors.indigo),
              title: Text("Semester $sem"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentListScreen(
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