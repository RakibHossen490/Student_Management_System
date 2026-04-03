import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../models/attendance.dart';
import '../../../services/attendance_service.dart';

class AttendanceEntryScreen extends StatefulWidget {
  final Student student;

  const AttendanceEntryScreen({super.key, required this.student});

  @override
  State<AttendanceEntryScreen> createState() => _AttendanceEntryScreenState();
}

class _AttendanceEntryScreenState extends State<AttendanceEntryScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final TextEditingController _daysController = TextEditingController();

  String _selectedMonth = "January";
  bool _isLoading = false;

  static const List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _saveAttendance() async {
    if (_daysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter days present")),
      );
      return;
    }

    final days = int.tryParse(_daysController.text);
    if (days == null || days < 0 || days > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number of days (0-31)")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const totalDays = 30;
      final percentage = (days / totalDays) * 100;

      final attendance = Attendance(
        id: '',
        studentId: widget.student.studentId,
        studentName: widget.student.name,
        month: _selectedMonth,
        attendedDays: days,
        totalDays: totalDays,
        percentage: percentage,
        timestamp: DateTime.now(),
      );

      await _attendanceService.saveAttendance(attendance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance saved successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving attendance: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.student.name} - Attendance"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student: ${widget.student.name}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("ID: ${widget.student.studentId}"),
                    Text("Department: ${widget.student.department}"),
                    Text("Semester: ${widget.student.semester}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _selectedMonth,
              decoration: const InputDecoration(
                labelText: "Select Month",
                border: OutlineInputBorder(),
              ),
              items: months
                  .map((month) => DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedMonth = value!),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Days Present (out of 30)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAttendance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save Attendance"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}