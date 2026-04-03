import 'package:flutter/material.dart';
import '../../../services/student_service.dart';
import '../../../models/student.dart';
import 'attendance_entry_screen.dart';
import 'attendance_history_screen.dart';

class AttendanceStudentScreen extends StatelessWidget {
  final String department;
  final String semester;

  const AttendanceStudentScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    final StudentService studentService = StudentService();

    return Scaffold(
      appBar: AppBar(
        title: Text("$department - Semester $semester Students"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Student>>(
        stream: studentService.getStudentsByDeptSem(department, semester),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No students found in this semester"),
            );
          }

          final students = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student.name[0].toUpperCase()),
                  ),
                  title: Text(student.name),
                  subtitle: Text("ID: ${student.studentId}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceEntryScreen(
                                student: student,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.history, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceHistoryScreen(
                                student: student,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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