import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine.dart';

class RoutineService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('routine');

  Stream<List<Routine>> getRoutineByDepartmentAndSemester(
      String department, String semester) {
    return collection
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Routine.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> uploadRoutine(Routine routine) async {
    await collection.add(routine.toFirestore());
  }

  Future<void> updateRoutine(String id, Routine routine) async {
    await collection.doc(id).update(routine.toFirestore());
  }

  Future<void> deleteRoutine(String id) async {
    await collection.doc(id).delete();
  }

  Stream<List<Routine>> getAllRoutine() {
    return collection
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Routine.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
