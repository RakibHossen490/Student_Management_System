import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Admin Login
  Future<UserModel?> adminLogin(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user is admin
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = UserModel.fromFirestore(userData, userDoc.id);
        if (user.role == UserRole.admin) {
          return user;
        }
      }

      // Not an admin, sign out
      await _auth.signOut();
      return null;
    } catch (e) {
      throw Exception('Admin login failed: $e');
    }
  }

  // Student Login
  Future<UserModel?> studentLogin(String name, String studentId, String phone, String department) async {
    try {
      // Check if student exists in students collection
      final studentQuery = await _firestore
          .collection('students')
          .where('name', isEqualTo: name)
          .where('studentId', isEqualTo: studentId)
          .where('phone', isEqualTo: phone)
          .where('department', isEqualTo: department)
          .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception('Student not found or credentials do not match');
      }

      final studentDoc = studentQuery.docs.first;
      final studentData = studentDoc.data();

      // Check if user account exists, if not create one
      final userQuery = await _firestore
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (userQuery.docs.isEmpty) {
        // Create user account
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: '$studentId@student.edu',
          password: phone, // Use phone as password for simplicity
        );

        final userModel = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: '$studentId@student.edu',
          studentId: studentId,
          phone: phone,
          department: department,
          semester: studentData['semester'],
          role: UserRole.student,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());

        return userModel;
      } else {
        // Sign in existing user
        await _auth.signInWithEmailAndPassword(
          email: '$studentId@student.edu',
          password: phone,
        );

        final userDoc = userQuery.docs.first;
        return UserModel.fromFirestore(userDoc.data(), userDoc.id);
      }
    } catch (e) {
      throw Exception('Student login failed: $e');
    }
  }

  // Register Admin
  Future<UserModel?> registerAdmin(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: UserRole.admin,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc.data()!, userDoc.id);
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Update profile image
  Future<void> updateProfileImage(String imageUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl,
      });
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).update(
        user.toFirestore(),
      );
    }
  }
}