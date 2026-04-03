import 'package:flutter/material.dart';
import 'result_semester_screen.dart';

class ResultDepartmentScreen extends StatelessWidget {
  const ResultDepartmentScreen({super.key});

  static const List<String> departments = [
    "CSE", "EEE", "ME", "TE", "Civil"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Department - Results"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.assignment, color: Colors.blue),
              title: Text(dept),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultSemesterScreen(department: dept),
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