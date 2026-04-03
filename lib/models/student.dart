import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String studentId;
  final String phone;
  final String department;
  final String semester;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.phone,
    required this.department,
    required this.semester,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      studentId: data['studentId'] ?? '',
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? '',
    );
  }
}