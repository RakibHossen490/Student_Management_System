import 'package:flutter/material.dart';
import 'attendance_semester_screen.dart';

class AttendanceDepartmentScreen extends StatelessWidget {
  static const List<String> departments = [
    "CSE", "EEE", "ME", "CE", "Civil"
  ];

  const AttendanceDepartmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Departments"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];

          return Card(
            child: ListTile(
              title: Text(dept),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceSemesterScreen(department: dept),
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