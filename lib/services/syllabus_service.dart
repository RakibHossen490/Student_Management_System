import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/syllabus.dart';

class SyllabusService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('syllabus');

  Stream<List<Syllabus>> getSyllabusByDepartmentAndSemester(
      String department, String semester) {
    return collection
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Syllabus.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> uploadSyllabus(Syllabus syllabus) async {
    await collection.add(syllabus.toFirestore());
  }

  Future<void> updateSyllabus(String id, Syllabus syllabus) async {
    await collection.doc(id).update(syllabus.toFirestore());
  }

  Future<void> deleteSyllabus(String id) async {
    await collection.doc(id).delete();
  }

  Stream<List<Syllabus>> getAllSyllabus() {
    return collection
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Syllabus.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
