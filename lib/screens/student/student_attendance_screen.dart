import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/attendance.dart';
import '../../services/attendance_service.dart';

class StudentAttendanceScreen extends StatelessWidget {
  final UserModel user;

  const StudentAttendanceScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final AttendanceService attendanceService = AttendanceService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Attendance"),
      ),
      body: StreamBuilder<List<Attendance>>(
        stream: attendanceService.getAttendanceForStudent(user.studentId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No attendance records found"),
            );
          }

          final attendanceRecords = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record.month,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: record.percentage >= 75
                                  ? Colors.green
                                  : record.percentage >= 60
                                      ? Colors.orange
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${record.percentage.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Days Present: ${record.attendedDays}/${record.totalDays}"),
                      Text(
                        "Date: ${record.timestamp.day}/${record.timestamp.month}/${record.timestamp.year}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}