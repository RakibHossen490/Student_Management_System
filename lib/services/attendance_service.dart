import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';

class AttendanceService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('attendance');

  Stream<List<Attendance>> getAttendanceForStudent(String studentId) {
    return collection
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Attendance.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> saveAttendance(Attendance attendance) async {
    await collection.add(attendance.toFirestore());
  }

  Future<void> updateAttendance(String id, Attendance attendance) async {
    await collection.doc(id).update(attendance.toFirestore());
  }

  Future<void> deleteAttendance(String id) async {
    await collection.doc(id).delete();
  }

  Stream<List<Attendance>> getAllAttendance() {
    return collection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Attendance.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}