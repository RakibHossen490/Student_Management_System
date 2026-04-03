import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../models/student.dart';

class DepartmentStudentScreen extends StatefulWidget {
  const DepartmentStudentScreen({super.key});

  @override
  State<DepartmentStudentScreen> createState() =>
      _DepartmentStudentScreenState();
}

class _DepartmentStudentScreenState
    extends State<DepartmentStudentScreen> {
  String department = "CSE";
  String semester = "1";

  final service = StudentService();

  final departments = ["CSE", "EEE", "ME", "TE","Civil" ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Students Table")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: department,
                  items: departments
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => department = val!),
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: semester,
                  items: List.generate(
                      8,
                      (i) => DropdownMenuItem(
                          value: (i + 1).toString(),
                          child: Text("Semester-${i + 1}"))),
                  onChanged: (val) =>
                      setState(() => semester = val!),
                ),
              ),
            ],
          ),

          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: service.getStudentsByDeptSem(
                  department, semester),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final students = snapshot.data!;

                return ListView(
                  children: students.map((s) {
                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(
                          "${s.studentId} | ${s.phone}"),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}