import 'package:flutter/material.dart';
import '../../models/result.dart';
import '../../services/result_service.dart';

class SyllabusUploadScreen extends StatefulWidget {
  final String department;
  final String semester;

  const SyllabusUploadScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<SyllabusUploadScreen> createState() => _SyllabusUploadScreenState();
}

class _SyllabusUploadScreenState extends State<SyllabusUploadScreen> {
  final ResultService _resultService = ResultService();
  final TextEditingController _titleController = TextEditingController();
  String _fileType = 'pdf';

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _uploadSyllabus() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // In a real app, you would upload the file to Firebase Storage
      // and get the download URL. For now, we'll simulate it.
      final syllabus = Result(
        id: '',
        department: widget.department,
        semester: widget.semester,
        title: _titleController.text.trim(),
        fileUrl: 'https://example.com/syllabus.pdf', // Placeholder
        fileType: _fileType,
        uploadedAt: DateTime.now(),
      );

      await _resultService.addResult(syllabus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Syllabus uploaded successfully')),
        );
        _titleController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading syllabus: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} - Semester ${widget.semester} - Syllabus"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upload New Syllabus",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Syllabus Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _fileType,
                      decoration: const InputDecoration(
                        labelText: "File Type",
                        border: OutlineInputBorder(),
                      ),
                      items: ['pdf', 'image', 'doc']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _fileType = value!),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _uploadSyllabus,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Upload Syllabus"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Existing Syllabus
            const Text(
              "Existing Syllabus:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<Result>>(
                stream: _resultService.getResultsByDeptSem(
                  widget.department,
                  widget.semester,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No syllabus uploaded yet"),
                    );
                  }

                  final syllabi = snapshot.data!;

                  return ListView.builder(
                    itemCount: syllabi.length,
                    itemBuilder: (context, index) {
                      final syllabus = syllabi[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            syllabus.fileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : syllabus.fileType == 'image'
                                    ? Icons.image
                                    : Icons.description,
                            color: Colors.green,
                          ),
                          title: Text(syllabus.title),
                          subtitle: Text(
                            "Uploaded: ${syllabus.uploadedAt.day}/${syllabus.uploadedAt.month}/${syllabus.uploadedAt.year}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Syllabus'),
                                  content: Text('Are you sure you want to delete "${syllabus.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _resultService.deleteResult(syllabus.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Syllabus deleted')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}