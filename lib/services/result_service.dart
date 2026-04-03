import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/result.dart';

class ResultService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('results');

  Stream<List<Result>> getResultsByDeptSem(String dept, String sem) {
    return collection
        .where('department', isEqualTo: dept)
        .where('semester', isEqualTo: sem)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Result.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addResult(Result result) async {
    await collection.add(result.toFirestore());
  }

  Future<void> deleteResult(String id) async {
    await collection.doc(id).delete();
  }

  Stream<List<Result>> getAllResults() {
    return collection
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Result.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}