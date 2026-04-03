import 'package:flutter/material.dart';
import 'syllabus_upload_screen.dart';
import 'routine_upload_screen.dart';

class SyllabusSemesterScreen extends StatefulWidget {
  final String department;

  const SyllabusSemesterScreen({super.key, required this.department});

  @override
  State<SyllabusSemesterScreen> createState() => _SyllabusSemesterScreenState();
}

class _SyllabusSemesterScreenState extends State<SyllabusSemesterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} - Select Semester"),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Syllabus", icon: Icon(Icons.book)),
            Tab(text: "Routine", icon: Icon(Icons.schedule)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Syllabus Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              final sem = semesters[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.class_, color: Colors.green),
                  title: Text("Semester $sem"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SyllabusUploadScreen(
                          department: widget.department,
                          semester: sem,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Routine Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              final sem = semesters[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.class_, color: Colors.blue),
                  title: Text("Semester $sem"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoutineUploadScreen(
                          department: widget.department,
                          semester: sem,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}