import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/phone_validator.dart';
import '../admin/admin_dashboard.dart';
import '../student/student_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  bool _isAdminLogin = true;
  bool _isLoading = false;
  String _phoneErrorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  bool _isValidPhone() {
    return PhoneValidator.isValidPhoneNumber(_phoneController.text);
  }

  void _validatePhone(String value) {
    setState(() {
      _phoneErrorMessage = PhoneValidator.getPhoneErrorMessage(value);
    });
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    // Validate student login fields
    if (!_isAdminLogin) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      if (_studentIdController.text.trim().isEmpty) {
        _showError('Please enter your student ID');
        return;
      }
      if (!_isValidPhone()) {
        _showError('Please enter a valid phone number (at least 10 digits)');
        return;
      }
      if (_departmentController.text.trim().isEmpty) {
        _showError('Please select a department');
        return;
      }
    } else {
      // Validate admin login
      if (_emailController.text.trim().isEmpty) {
        _showError('Please enter your email');
        return;
      }
      if (_passwordController.text.isEmpty) {
        _showError('Please enter your password');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      UserModel? user;
      if (_isAdminLogin) {
        user = await _authService.adminLogin(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        user = await _authService.studentLogin(
          _nameController.text.trim(),
          _studentIdController.text.trim(),
          _phoneController.text.trim(),
          _departmentController.text.trim(),
        );
      }

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => user!.role == UserRole.admin
                ? AdminDashboard(user: user!)
                : StudentDashboard(user: user!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(_parseErrorMessage(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _parseErrorMessage(String error) {
    if (error.contains('Invalid Student ID or Phone Number')) {
      return 'Invalid Student ID or Phone Number. Please check your credentials.';
    }
    if (error.contains('Student ID not found')) {
      return 'Student ID not found in the system. Please contact the admin.';
    }
    if (error.contains('Invalid phone number')) {
      return 'Invalid phone number format. Please enter at least 10 digits.';
    }
    if (error.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Invalid credentials. Please check your email and password.';
    }
    if (error.contains('user-not-found')) {
      return 'User account not found. Please check your student ID or contact admin.';
    }
    if (error.contains('wrong-password')) {
      return 'Invalid phone number. Please enter the correct phone number used during registration.';
    }
    return error.replaceAll('Exception: ', '').replaceAll('Student login failed: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "ICE Student Management",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Type Toggle
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isAdminLogin = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAdminLogin ? Colors.blue : Colors.grey,
                            ),
                            child: const Text("Admin Login"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isAdminLogin = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isAdminLogin ? Colors.blue : Colors.grey,
                            ),
                            child: const Text("Student Login"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (_isAdminLogin) ...[
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Password"),
                      ),
                    ] else ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Full Name"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _studentIdController,
                        decoration: const InputDecoration(labelText: "Student ID"),
                      ),
                      const SizedBox(height: 10),
                      
                      // Phone Number Field with Validation
                      TextField(
                        controller: _phoneController,
                        onChanged: _validatePhone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          hintText: "e.g., 9876543210 or 987-654-3210",
                          helperText: _isValidPhone() 
                              ? "✓ Valid phone number"
                              : "Enter at least 10 digits",
                          helperMaxLines: 2,
                          errorText: _phoneErrorMessage.isEmpty ? null : _phoneErrorMessage,
                          suffixIcon: _phoneController.text.isEmpty
                              ? null
                              : _isValidPhone()
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.error, color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _phoneErrorMessage.isNotEmpty
                                  ? Colors.red
                                  : _isValidPhone()
                                      ? Colors.green
                                      : Colors.grey,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _departmentController.text.isEmpty ? null : _departmentController.text,
                        decoration: const InputDecoration(labelText: "Department"),
                        items: ['CSE', 'EEE', 'ME', 'TE', 'Civil']
                            .map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ))
                            .toList(),
                        onChanged: (value) => _departmentController.text = value ?? '',
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Login"),
                      ),
                    ),

                    if (_isAdminLogin) ...[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text("Create Admin Account"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}