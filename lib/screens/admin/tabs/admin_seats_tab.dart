import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/seat_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';

class AdminSeatsTab extends StatefulWidget {
  const AdminSeatsTab({super.key});

  @override
  State<AdminSeatsTab> createState() => _AdminSeatsTabState();
}

class _AdminSeatsTabState extends State<AdminSeatsTab> {
  List<SeatModel> _seats = [];
  Map<String, StudentModel> _studentMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId == null) { setState(() => _loading = false); return; }
    try {
      final seats = await AppProviders.dbService.getSeats(libraryId);
      final students = await AppProviders.dbService.getStudents(libraryId);
      final studentMap = { for (final s in students) s.id: s };
      if (mounted) setState(() { _seats = seats; _studentMap = studentMap; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSeatDetails(SeatModel seat) {
    final student = seat.studentId != null ? _studentMap[seat.studentId] : null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Seat ${seat.number}'),
        content: seat.occupied && student != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: student.photoUrl.isNotEmpty ? NetworkImage(student.photoUrl) : null,
                    child: student.photoUrl.isEmpty ? Text(student.name[0], style: const TextStyle(fontSize: 24)) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(student.mobile, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 4,
                    children: [
                      Chip(label: Text(student.seatType), backgroundColor: Colors.blue.shade50),
                      Chip(label: Text(student.studyTime), backgroundColor: Colors.green.shade50),
                    ],
                  ),
                ],
              )
            : const Text('This seat is currently free.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final occupied = _seats.where((s) => s.occupied).length;
    final free = _seats.where((s) => !s.occupied).length;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  // Stats bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(child: _SeatStatCard(label: 'Total', value: _seats.length, color: Colors.blue)),
                        const SizedBox(width: 8),
                        Expanded(child: _SeatStatCard(label: 'Occupied', value: occupied, color: Colors.red)),
                        const SizedBox(width: 8),
                        Expanded(child: _SeatStatCard(label: 'Free', value: free, color: Colors.green)),
                      ],
                    ),
                  ),
                  // Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _LegendDot(color: Colors.green.shade400, label: 'Free'),
                        const SizedBox(width: 16),
                        _LegendDot(color: Colors.red.shade400, label: 'Occupied'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Grid
                  Expanded(
                    child: _seats.isEmpty
                        ? const Center(child: Text('No seats found.\nSeats are auto-created when students are added.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _seats.length,
                            itemBuilder: (ctx, i) {
                              final seat = _seats[i];
                              return GestureDetector(
                                onTap: () => _showSeatDetails(seat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: seat.occupied ? Colors.red.shade400 : Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_seat, size: 22, color: Colors.white),
                                      Text('${seat.number}',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SeatStatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _SeatStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
