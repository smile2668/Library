import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/attendance_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';

class AdminAttendanceTab extends StatefulWidget {
  const AdminAttendanceTab({super.key});

  @override
  State<AdminAttendanceTab> createState() => _AdminAttendanceTabState();
}

class _AdminAttendanceTabState extends State<AdminAttendanceTab> {
  DateTime _selectedDate = DateTime.now();
  List<AttendanceModel> _records = [];
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
      final records = await AppProviders.dbService.getAttendance(libraryId, date: _selectedDate);
      final students = await AppProviders.dbService.getStudents(libraryId);
      final studentMap = { for (final s in students) s.id: s };
      if (mounted) setState(() { _records = records; _studentMap = studentMap; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; _loading = true; });
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final present = _records.where((r) => r.status == 'Present').length;
    final absent = _records.where((r) => r.status == 'Absent').length;

    return Scaffold(
      body: Column(
        children: [
          // Date picker bar
          InkWell(
            onTap: _pickDate,
            child: Container(
              color: const Color(0xFF3949AB).withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Color(0xFF3949AB)),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF3949AB)),
                ],
              ),
            ),
          ),
          // Stats row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _AttendStatCard(label: 'Total', value: _records.length, color: Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _AttendStatCard(label: 'Present', value: present, color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _AttendStatCard(label: 'Absent', value: absent, color: Colors.red)),
              ],
            ),
          ),
          // Records list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.how_to_reg_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No attendance records for this date', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          TextButton(onPressed: _pickDate, child: const Text('Pick another date')),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _records.length,
                          itemBuilder: (ctx, i) {
                            final r = _records[i];
                            final student = _studentMap[r.studentId];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: r.status == 'Present' ? Colors.green.shade100 : Colors.red.shade100,
                                  child: Icon(
                                    r.status == 'Present' ? Icons.check : Icons.close,
                                    color: r.status == 'Present' ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(student?.name ?? r.studentId, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  'Seat ${student?.seatNumber ?? '-'} • ${DateFormat('hh:mm a').format(r.timestamp)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: r.status == 'Present' ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    r.status,
                                    style: TextStyle(
                                      color: r.status == 'Present' ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _AttendStatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _AttendStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
