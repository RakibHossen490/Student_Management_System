import 'package:cloud_firestore/cloud_firestore.dart';

class Routine {
  final String id;
  final String department;
  final String semester;
  final String title;
  final String fileUrl;
  final String fileType; // 'pdf', 'image', 'doc'
  final DateTime uploadedAt;

  Routine({
    required this.id,
    required this.department,
    required this.semester,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  factory Routine.fromFirestore(Map<String, dynamic> data, String id) {
    return Routine(
      id: id,
      department: data['department'] ?? '',
      semester: data['semester'] ?? '',
      title: data['title'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileType: data['fileType'] ?? 'pdf',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'department': department,
      'semester': semester,
      'title': title,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
