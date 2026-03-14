import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/attendance_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';
import '../qr_scanner_screen.dart';

class StudentAttendanceTab extends StatefulWidget {
  const StudentAttendanceTab({super.key});

  @override
  State<StudentAttendanceTab> createState() => _StudentAttendanceTabState();
}

class _StudentAttendanceTabState extends State<StudentAttendanceTab> {
  List<AttendanceModel> _history = [];
  bool _loading = true;
  AttendanceModel? _todaysRecord;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (userId == null || libraryId == null) { setState(() => _loading = false); return; }
    try {
      final all = await AppProviders.dbService.getAttendance(libraryId);
      final studentAll = all.where((a) => a.studentId == userId).toList();
      final today = DateTime.now();
      final todaysRecord = studentAll.where((a) =>
        a.timestamp.year == today.year &&
        a.timestamp.month == today.month &&
        a.timestamp.day == today.day
      ).firstOrNull;
      if (mounted) setState(() {
        _history = studentAll..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _todaysRecord = todaysRecord;
        _loading = false;
      });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); }
    }
  }

  int get _presentCount => _history.where((a) => a.status == 'Present').length;

  double get _attendancePercentage {
    if (_history.isEmpty) return 0;
    return _presentCount / _history.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Today's status card
                  Card(
                    color: _todaysRecord?.status == 'Present'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            _todaysRecord?.status == 'Present' ? Icons.check_circle : Icons.schedule,
                            size: 48,
                            color: _todaysRecord?.status == 'Present' ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _todaysRecord?.status == 'Present' ? 'Present Today ✓' : 'Not Marked Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _todaysRecord?.status == 'Present' ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                          if (_todaysRecord != null)
                            Text(
                              'Checked in at ${DateFormat('hh:mm a').format(_todaysRecord!.timestamp)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Scan button
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                        );
                        if (result == true) await _load();
                      },
                      icon: const Icon(Icons.qr_code_scanner, size: 24),
                      label: const Text('Scan QR Code to Mark Attendance', style: TextStyle(fontSize: 15)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE64A19),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(children: [
                    Expanded(child: _StatChip(label: 'Total Days', value: '${_history.length}', color: Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Present', value: '$_presentCount', color: Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Percentage', value: '${_attendancePercentage.toStringAsFixed(0)}%', color: Colors.purple)),
                  ]),
                  const SizedBox(height: 16),

                  // Attendance history
                  const Text('Attendance History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Center(child: Text('No attendance records yet', style: TextStyle(color: Colors.grey)))
                  else
                    ...(_history.take(30).map((record) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: record.status == 'Present' ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            record.status == 'Present' ? Icons.check : Icons.close,
                            color: record.status == 'Present' ? Colors.green : Colors.red,
                            size: 18,
                          ),
                        ),
                        title: Text(DateFormat('EEEE, dd MMM yyyy').format(record.timestamp)),
                        subtitle: Text(DateFormat('hh:mm a').format(record.timestamp)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: record.status == 'Present' ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            record.status,
                            style: TextStyle(
                              color: record.status == 'Present' ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ))),
                ],
              ),
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
