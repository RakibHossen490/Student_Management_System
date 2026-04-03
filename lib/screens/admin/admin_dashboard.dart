import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import 'add_student_screen.dart';
import 'department_screen.dart';
import 'attendance/attendance_department_screen.dart';
import 'result_department_screen.dart';
import 'syllabus_department_screen.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel user;

  const AdminDashboard({super.key, required this.user});

  Widget buildButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, _) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeService.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${user.name}!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Management Options:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  buildButton(
                    context,
                    "Student Management",
                    Icons.people,
                    const DepartmentScreen(),
                  ),
                  buildButton(
                    context,
                    "Attendance",
                    Icons.check_circle,
                    const AttendanceDepartmentScreen(),
                  ),
                  buildButton(
                    context,
                    "Results",
                    Icons.assignment,
                    const ResultDepartmentScreen(),
                  ),
                  buildButton(
                    context,
                    "Syllabus & Routine",
                    Icons.book,
                    const SyllabusDepartmentScreen(),
                  ),
                  buildButton(
                    context,
                    "Add Student",
                    Icons.person_add,
                    const AddStudentScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}