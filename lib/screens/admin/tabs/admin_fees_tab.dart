import 'package:flutter/material.dart';

class AdminFeesTab extends StatelessWidget {
  const AdminFeesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Expanded(child: Text('Fees Dashboard')),
              DropdownButton<String>(
                value: '1 Month',
                items: const ['1 Month', '3 Months', '6 Months', '1 Year']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (_) {},
              )
            ],
          ),
        ),
        const Expanded(
          child: ListTile(
            title: Text('Student Name • Seat Number'),
            subtitle: Text('Due Date • Payment Status (Paid/Pending) • Method'),
          ),
        )
      ],
    );
  }
}
