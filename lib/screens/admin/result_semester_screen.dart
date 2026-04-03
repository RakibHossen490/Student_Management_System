import 'package:flutter/material.dart';
import 'result_upload_screen.dart';

class ResultSemesterScreen extends StatelessWidget {
  final String department;

  const ResultSemesterScreen({super.key, required this.department});

  static const List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$department - Select Semester - Results"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          final sem = semesters[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.class_, color: Colors.blue),
              title: Text("Semester $sem"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultUploadScreen(
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