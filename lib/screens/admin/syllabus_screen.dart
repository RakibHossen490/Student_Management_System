import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String? fileName;

  void pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
    }
  }

  void upload() {
    if (fileName == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Uploaded: $fileName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Syllabus")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text("Pick File"),
            ),
            const SizedBox(height: 10),
            Text(fileName ?? "No file selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: upload,
              child: const Text("Upload"),
            )
          ],
        ),
      ),
    );
  }
}