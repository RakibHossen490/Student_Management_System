import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/result.dart';
import '../../services/result_service.dart';

class ViewSyllabusScreen extends StatelessWidget {
  final UserModel user;

  const ViewSyllabusScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final ResultService resultService = ResultService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Syllabus & Routine"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Result>>(
        stream: resultService.getResultsByDeptSem(
          user.department!,
          user.semester!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No syllabus or routine available for your semester"),
            );
          }

          final syllabi = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: syllabi.length,
            itemBuilder: (context, index) {
              final syllabus = syllabi[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    syllabus.fileType == 'pdf'
                        ? Icons.picture_as_pdf
                        : syllabus.fileType == 'image'
                            ? Icons.image
                            : Icons.description,
                    color: Colors.green,
                    size: 40,
                  ),
                  title: Text(
                    syllabus.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Uploaded: ${syllabus.uploadedAt.day}/${syllabus.uploadedAt.month}/${syllabus.uploadedAt.year}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: Colors.blue),
                    onPressed: () {
                      // In a real app, this would download/open the file
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Downloading ${syllabus.title}")),
                      );
                    },
                  ),
                  onTap: () {
                    // View the syllabus file
                    _viewSyllabus(context, syllabus);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewSyllabus(BuildContext context, Result syllabus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(syllabus.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Department: ${syllabus.department}"),
            Text("Semester: ${syllabus.semester}"),
            Text("Type: ${syllabus.fileType.toUpperCase()}"),
            const SizedBox(height: 16),
            const Text("File preview would be shown here"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              // Download logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Download started")),
              );
            },
            child: const Text("Download"),
          ),
        ],
      ),
    );
  }
}
