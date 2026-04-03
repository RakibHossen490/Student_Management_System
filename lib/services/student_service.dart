import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('students');

  Stream<List<Student>> getStudents() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<Student>> getStudentsByDeptSem(
      String dept, String sem) {
    return collection
        .where('department', isEqualTo: dept)
        .where('semester', isEqualTo: sem)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addStudent(Student student) async {
    await collection.add({
      'name': student.name,
      'studentId': student.studentId,
      'phone': student.phone,
      'department': student.department,
      'semester': student.semester,
    });
  }

  Future<void> updateStudent(String id, Student student) async {
    await collection.doc(id).update({
      'name': student.name,
      'studentId': student.studentId,
      'phone': student.phone,
      'department': student.department,
      'semester': student.semester,
    });
  }

  Future<void> deleteStudent(String id) async {
    await collection.doc(id).delete();
  }

  Future<Student?> getStudentById(String id) async {
    final doc = await collection.doc(id).get();
    if (doc.exists) {
      return Student.fromFirestore(doc);
    }
    return null;
  }
}