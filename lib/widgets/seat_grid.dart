import 'package:flutter/material.dart';

import '../models/seat_model.dart';

class SeatGrid extends StatelessWidget {
  final List<SeatModel> seats;

  const SeatGrid({super.key, required this.seats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.2),
      itemCount: seats.length,
      itemBuilder: (_, i) {
        final seat = seats[i];
        return Card(
          color: seat.occupied ? Colors.red.shade300 : Colors.green.shade300,
          child: Center(child: Text('S${seat.number}')),
        );
      },
    );
  }
}
