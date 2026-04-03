import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/result.dart';
import '../../services/result_service.dart';
import '../../services/file_storage_service.dart';

class ResultUploadScreen extends StatefulWidget {
  final String department;
  final String semester;

  const ResultUploadScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<ResultUploadScreen> createState() => _ResultUploadScreenState();
}

class _ResultUploadScreenState extends State<ResultUploadScreen> {
  final ResultService _resultService = ResultService();
  final FileStorageService _fileStorageService = FileStorageService();
  final TextEditingController _titleController = TextEditingController();
  
  String _fileType = 'pdf';
  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
          
          // Detect file type
          if (_selectedFileName != null) {
            if (_selectedFileName!.endsWith('.pdf')) {
              _fileType = 'pdf';
            } else if (_selectedFileName!.endsWith('.doc') || 
                       _selectedFileName!.endsWith('.docx')) {
              _fileType = 'doc';
            } else {
              _fileType = 'image';
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadResult() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload file to Firebase Storage
      final fileUrl = await _fileStorageService.uploadResultFile(
        _selectedFile!,
        widget.semester,
        _titleController.text.trim(),
        _selectedFileName!,
      );

      // Save metadata to Firestore
      final result = Result(
        id: '',
        department: widget.department,
        semester: widget.semester,
        title: _titleController.text.trim(),
        fileUrl: fileUrl,
        fileType: _fileType,
        uploadedAt: DateTime.now(),
      );

      await _resultService.addResult(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result uploaded successfully')),
        );
        _titleController.clear();
        setState(() {
          _selectedFile = null;
          _selectedFileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading result: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No file selected',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected File:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(_selectedFileName ?? 'Unknown'),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () {
              setState(() {
                _selectedFile = null;
                _selectedFileName = null;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} - Semester ${widget.semester} - Results"),
      ),
      body: SingleChildScrollView(
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
                      "Upload New Result",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Input
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Result Title",
                        hintText: "E.g., Mid Term Exam Results",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // File Type Selection
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

                    // File Picker Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Choose File"),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // File Preview
                    _buildFilePreview(),
                    const SizedBox(height: 12),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadResult,
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Upload Result'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // View Results Section
            const Text(
              "Uploaded Results:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<Result>>(
              stream: _resultService.getResultsByDeptSem(
                widget.department,
                widget.semester,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No results uploaded yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: results.map((result) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(result.title),
                        subtitle: Text(
                          'Uploaded: ${result.uploadedAt.toString().split('.')[0]}',
                        ),
                        leading: Icon(
                          result.fileType == 'pdf'
                              ? Icons.picture_as_pdf
                              : result.fileType == 'doc'
                                  ? Icons.description
                                  : Icons.image,
                          color: Colors.blue,
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () {
                                _resultService.deleteResult(result.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}