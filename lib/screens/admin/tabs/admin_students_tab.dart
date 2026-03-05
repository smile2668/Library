import 'package:flutter/material.dart';

class AdminStudentsTab extends StatelessWidget {
  const AdminStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('Add Student'),
        ),
        const SizedBox(height: 12),
        const ListTile(
          title: Text('Student Name'),
          subtitle: Text('Mobile • Seat No • Seat Type • Study Time'),
        )
      ],
    );
  }
}
