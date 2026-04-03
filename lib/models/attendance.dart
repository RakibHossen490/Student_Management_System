import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String studentId;
  final String studentName;
  final String month;
  final int attendedDays;
  final int totalDays;
  final double percentage;
  final DateTime timestamp;

  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.month,
    required this.attendedDays,
    required this.totalDays,
    required this.percentage,
    required this.timestamp,
  });

  factory Attendance.fromFirestore(Map<String, dynamic> data, String id) {
    return Attendance(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      month: data['month'] ?? '',
      attendedDays: data['attendedDays'] ?? 0,
      totalDays: data['totalDays'] ?? 30,
      percentage: data['percentage'] ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'month': month,
      'attendedDays': attendedDays,
      'totalDays': totalDays,
      'percentage': percentage,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}