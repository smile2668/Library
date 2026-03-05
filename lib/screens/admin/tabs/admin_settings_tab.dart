import 'package:flutter/material.dart';

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ListTile(title: Text('Library Name'), subtitle: Text('Update profile and logo')),
        ListTile(title: Text('Total Seats'), subtitle: Text('Adjust seat capacity')),
        ListTile(title: Text('Push Notifications'), subtitle: Text('Configure fee reminders')),
      ],
    );
  }
}
