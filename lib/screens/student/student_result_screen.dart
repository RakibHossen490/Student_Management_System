import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/result.dart';
import '../../services/result_service.dart';

class StudentResultScreen extends StatefulWidget {
  final UserModel user;

  const StudentResultScreen({super.key, required this.user});

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  late final ResultService _resultService;

  @override
  void initState() {
    super.initState();
    _resultService = ResultService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Results"),
      ),
      body: StreamBuilder<List<Result>>(
        stream: _resultService.getResultsByDeptSem(
          widget.user.department!,
          widget.user.semester!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No results available for your semester"),
            );
          }

          final results = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.blue),
                  title: Text(result.title),
                  subtitle: Text(
                    "Uploaded: ${result.uploadedAt.day}/${result.uploadedAt.month}/${result.uploadedAt.year}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // In a real app, this would open/download the file
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Downloading ${result.title}")),
                      );
                    },
                  ),
                  onTap: () {
                    // View the result file
                    _viewResult(context, result);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewResult(BuildContext context, Result result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Department: ${result.department}"),
            Text("Semester: ${result.semester}"),
            Text("Type: ${result.fileType.toUpperCase()}"),
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