import 'package:cloud_firestore/cloud_firestore.dart';

class Syllabus {
  final String id;
  final String department;
  final String semester;
  final String subject;
  final String title;
  final String fileUrl;
  final String fileType; // 'pdf', 'image', 'doc'
  final DateTime uploadedAt;

  Syllabus({
    required this.id,
    required this.department,
    required this.semester,
    required this.subject,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  factory Syllabus.fromFirestore(Map<String, dynamic> data, String id) {
    return Syllabus(
      id: id,
      department: data['department'] ?? '',
      semester: data['semester'] ?? '',
      subject: data['subject'] ?? '',
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
      'subject': subject,
      'title': title,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
