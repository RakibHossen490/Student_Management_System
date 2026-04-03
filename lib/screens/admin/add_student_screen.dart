import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() =>
      _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final name = TextEditingController();
  final id = TextEditingController();
  final phone = TextEditingController();

  String department = "CSE";
  String semester = "1";

  final departments = ["CSE", "EEE", "Civil", "ME", "TE"];

  void saveStudent() async {
    await FirebaseFirestore.instance.collection('students').add({
      "name": name.text,
      "studentId": id.text,
      "phone": phone.text,
      "department": department,
      "semester": semester,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student Added")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Student")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: id, decoration: const InputDecoration(labelText: "ID")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),

            DropdownButton<String>(
              value: department,
              items: departments
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => department = val!),
            ),

            DropdownButton<String>(
              value: semester,
              items: List.generate(
                  8,
                  (i) => DropdownMenuItem(
                        value: (i + 1).toString(),
                        child: Text("Semester-${i + 1}"),
                      )),
              onChanged: (val) => setState(() => semester = val!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveStudent,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}