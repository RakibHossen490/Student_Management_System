import 'package:flutter/material.dart';
import 'syllabus_semester_screen.dart';

class SyllabusDepartmentScreen extends StatelessWidget {
  const SyllabusDepartmentScreen({super.key});

  static const List<String> departments = [
    "CSE", "EEE", "ME", "TE", "Civil"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Department - Syllabus"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.green),
              title: Text(dept),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SyllabusSemesterScreen(department: dept),
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