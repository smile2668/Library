import 'package:flutter/material.dart';

class AdminAttendanceTab extends StatelessWidget {
  const AdminAttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, i) => ListTile(
        title: Text('Attendance Request #$i'),
        subtitle: const Text('Student • Time • Pending'),
        trailing: Wrap(
          spacing: 8,
          children: [
            OutlinedButton(onPressed: () {}, child: const Text('Reject')),
            FilledButton(onPressed: () {}, child: const Text('Accept')),
          ],
        ),
      ),
    );
  }
}
