import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../models/student.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final StudentService service = StudentService();

  Map<String, bool> attendance = {};

  void toggleAttendance(String id) {
    setState(() {
      attendance[id] = !(attendance[id] ?? false);
    });
  }

  void saveAttendance() {
    // 🔥 future এ Firebase এ save করবো
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance Saved (Demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      body: StreamBuilder<List<Student>>(
        stream: service.getStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    return CheckboxListTile(
                      title: Text(student.name),
                      subtitle: Text(student.studentId),
                      value: attendance[student.id] ?? false,
                      onChanged: (_) {
                        toggleAttendance(student.id);
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: saveAttendance,
                  child: const Text("Save Attendance"),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}