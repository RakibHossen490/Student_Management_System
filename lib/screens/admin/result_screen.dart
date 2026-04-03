import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../models/student.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final StudentService service = StudentService();

  Map<String, TextEditingController> marksController = {};

  void saveResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Result Saved (Demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
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

                    marksController.putIfAbsent(
                        student.id, () => TextEditingController());

                    return ListTile(
                      title: Text(student.name),
                      subtitle: Text(student.studentId),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: marksController[student.id],
                          decoration:
                              const InputDecoration(hintText: "Marks"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: saveResult,
                child: const Text("Save Result"),
              )
            ],
          );
        },
      ),
    );
  }
}