import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/phone_validator.dart';

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

  // Student Login - Optimized with caching and phone normalization
  Future<UserModel?> studentLogin(String name, String studentId, String phone, String department) async {
    try {
      // Normalize phone number to remove formatting
      final normalizedPhone = PhoneValidator.normalizePhoneNumber(phone);
      
      // Validate phone number
      if (!PhoneValidator.isValidPhoneNumber(normalizedPhone)) {
        throw Exception('Invalid phone number. Please enter at least 10 digits.');
      }

      // Try to sign in first if account exists (fast path)
      try {
        await _auth.signInWithEmailAndPassword(
          email: '$studentId@student.edu',
          password: normalizedPhone,
        );

        // If sign in succeeds, fetch user data from Firestore
        final userQuery = await _firestore
            .collection('users')
            .where('studentId', isEqualTo: studentId)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          return UserModel.fromFirestore(userQuery.docs.first.data(), userQuery.docs.first.id);
        }
      } catch (e) {
        // Account doesn't exist, proceed with creation
        // Or wrong password, which will be caught by new account creation and a proper error will be shown
        if (e.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
          throw Exception('Invalid Student ID or Phone Number');
        }
      }

      // New account - validate against students collection
      final studentQuery = await _firestore
          .collection('students')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception('Student ID not found in system');
      }

      final studentData = studentQuery.docs.first.data();
      
      // Verify phone number matches (optional but recommended for security)
      // Uncomment if you want to verify stored phone during login
      // final storedPhone = studentData['phone'] ?? '';
      // if (PhoneValidator.normalizePhoneNumber(storedPhone) != normalizedPhone) {
      //   throw Exception('Phone number does not match our records');
      // }

      // Create new user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$studentId@student.edu',
        password: normalizedPhone,
      );

      final userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: '$studentId@student.edu',
        studentId: studentId,
        phone: normalizedPhone,
        department: department,
        semester: studentData['semester'],
        role: UserRole.student,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
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