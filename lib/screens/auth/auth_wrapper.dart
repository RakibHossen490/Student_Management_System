import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../admin/admin_dashboard.dart';
import '../student/student_dashboard.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  UserModel? _cachedUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _cachedUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedUser = null;
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;
        
        // No Firebase user, show login
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        // Firebase user exists, show appropriate dashboard if we have cached user data
        if (!_isLoadingUser && _cachedUser != null) {
          return _cachedUser!.role == UserRole.admin
              ? AdminDashboard(user: _cachedUser!)
              : StudentDashboard(user: _cachedUser!);
        }

        // Still loading user data from Firestore
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading dashboard...'),
              ],
            ),
          ),
        );
      },
    );
  }
}