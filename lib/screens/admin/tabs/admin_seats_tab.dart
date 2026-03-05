import 'package:flutter/material.dart';

import '../../../models/seat_model.dart';
import '../../../widgets/seat_grid.dart';

class AdminSeatsTab extends StatelessWidget {
  const AdminSeatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final seats = List.generate(
      24,
      (i) => SeatModel(id: '$i', libraryId: 'demo', number: i + 1, occupied: i.isOdd),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seat Availability Dashboard', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SeatGrid(seats: seats),
        ],
      ),
    );
  }
}
