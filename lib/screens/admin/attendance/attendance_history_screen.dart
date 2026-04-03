import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../models/attendance.dart';
import '../../../services/attendance_service.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final Student student;

  const AttendanceHistoryScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final AttendanceService attendanceService = AttendanceService();

    return Scaffold(
      appBar: AppBar(
        title: Text("${student.name} - Attendance History"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Attendance>>(
        stream: attendanceService.getAttendanceForStudent(student.studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No attendance records found"),
            );
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
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