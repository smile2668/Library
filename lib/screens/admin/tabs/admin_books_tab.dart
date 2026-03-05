import 'package:flutter/material.dart';

class AdminBooksTab extends StatelessWidget {
  const AdminBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, i) => ListTile(
        title: Text('Book request #$i'),
        subtitle: const Text('Book Name • Pending'),
        trailing: Wrap(
          spacing: 8,
          children: [
            OutlinedButton(onPressed: () {}, child: const Text('Reject')),
            FilledButton(onPressed: () {}, child: const Text('Approve')),
          ],
        ),
      ),
    );
  }
}
