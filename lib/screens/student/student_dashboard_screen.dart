import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(child: ListTile(title: Text('Seat Details'), subtitle: Text('Seat No, type, study time'))),
          Card(child: ListTile(title: Text('Attendance'), subtitle: Text('Mark attendance & view logs'))),
          Card(child: ListTile(title: Text('Fees Status'), subtitle: Text('Due date, status, payment mode'))),
          Card(child: ListTile(title: Text('Book Requests'), subtitle: Text('Request book with image upload'))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Mark Attendance'),
        icon: const Icon(Icons.how_to_reg),
      ),
    );
  }
}
