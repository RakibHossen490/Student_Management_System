import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/result.dart';
import '../../services/result_service.dart';
import '../../services/file_storage_service.dart';

class RoutineUploadScreen extends StatefulWidget {
  final String department;
  final String semester;

  const RoutineUploadScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<RoutineUploadScreen> createState() => _RoutineUploadScreenState();
}

class _RoutineUploadScreenState extends State<RoutineUploadScreen> {
  final ResultService _resultService = ResultService();
  final FileStorageService _fileStorageService = FileStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  
  String _fileType = 'image';
  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _selectedFileName = image.name;
          _fileType = 'image';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadRoutine() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file or image')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload file to Firebase Storage
      final fileUrl = await _fileStorageService.uploadRoutineFile(
        _selectedFile!,
        widget.semester,
        _selectedFileName!,
      );

      // Save metadata to Firestore
      final routine = Result(
        id: '',
        department: widget.department,
        semester: widget.semester,
        title: _titleController.text.trim(),
        fileUrl: fileUrl,
        fileType: _fileType,
        uploadedAt: DateTime.now(),
      );

      await _resultService.addResult(routine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine uploaded successfully')),
        );
        _titleController.clear();
        setState(() {
          _selectedFile = null;
          _selectedFileName = null;
          _fileType = 'image';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading routine: ${e.toString()}')),
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
          Row(
            children: [
              Icon(
                _fileType == 'pdf'
                    ? Icons.picture_as_pdf
                    : _fileType == 'image'
                        ? Icons.image
                        : Icons.description,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFileName ?? 'Unknown',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (_fileType == 'image')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  _selectedFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} - Semester ${widget.semester} - Routine"),
        backgroundColor: Colors.blue,
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
                      "Upload New Routine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Routine Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // File Preview
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildFilePreview(),
                    ),
                    const SizedBox(height: 16),

                    // Image Picker Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Choose Image"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // File Picker Button (Alternative)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text("Choose File (PDF/Image/DOC)"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadRoutine,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.upload),
                        label: Text(
                          _isUploading ? "Uploading..." : "Upload Routine",
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Existing Routines
            const Text(
              "Existing Routines:",
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
                      child: Text("No routine uploaded yet"),
                    );
                  }

                  final routines = snapshot.data!;

                  return ListView.builder(
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            routine.fileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: Colors.blue,
                          ),
                          title: Text(routine.title),
                          subtitle: Text(
                            "Uploaded: ${routine.uploadedAt.day}/${routine.uploadedAt.month}/${routine.uploadedAt.year}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Routine'),
                                  content: Text('Are you sure you want to delete "${routine.title}"?'),
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
                                await _resultService.deleteResult(routine.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Routine deleted')),
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
