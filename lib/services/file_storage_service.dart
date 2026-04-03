import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file for results
  Future<String> uploadResultFile(
    File file,
    String semester,
    String subject,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child(
          'results/$semester/$subject/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload result file: ${e.toString()}');
    }
  }

  // Upload file for syllabus
  Future<String> uploadSyllabusFile(
    File file,
    String semester,
    String subject,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child(
          'syllabus/$semester/$subject/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload syllabus file: ${e.toString()}');
    }
  }

  // Upload file for routine
  Future<String> uploadRoutineFile(
    File file,
    String semester,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child(
          'routine/$semester/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload routine file: ${e.toString()}');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  // Delete file
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  // Get download URL for a file path
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: ${e.toString()}');
    }
  }
}
