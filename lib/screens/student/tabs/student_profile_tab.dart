import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/fee_model.dart';
import '../../../models/student_model.dart';
import '../../../models/study_session_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';

class StudentProfileTab extends StatefulWidget {
  const StudentProfileTab({super.key});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  StudentModel? _student;
  List<FeeModel> _fees = [];
  List<StudySessionModel> _sessions = [];
  bool _loading = true;

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
      final students = await AppProviders.dbService.getStudents(libraryId);
      final student = students.where((s) => s.id == userId).firstOrNull;
      final fees = await AppProviders.dbService.getFees(libraryId);
      final myFees = fees.where((f) => f.studentId == userId).toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
      final allSessions = await AppProviders.dbService.getStudySessions(libraryId);
      final sessions = allSessions.where((s) => s.studentId == userId).toList();
      if (mounted) setState(() {
        _student = student;
        _fees = myFees;
        _sessions = sessions;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalStudyMinutes =>
      _sessions.fold(0, (sum, s) => sum + (s.durationMinutes ?? 0));

  int get _thisMonthMinutes {
    final now = DateTime.now();
    return _sessions
        .where((s) => s.startTime.year == now.year && s.startTime.month == now.month)
        .fold(0, (sum, s) => sum + (s.durationMinutes ?? 0));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
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
                  // Profile header
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color(0xFFE64A19).withValues(alpha: 0.12),
                            backgroundImage: _student?.photoUrl.isNotEmpty == true ? NetworkImage(_student!.photoUrl) : null,
                            child: _student?.photoUrl.isEmpty != false
                                ? Text(
                                    _student?.name.isNotEmpty == true ? _student!.name[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE64A19)),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _student?.name ?? 'Loading...',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(_student?.mobile ?? '', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 4, children: [
                            Chip(
                              label: Text('Seat ${_student?.seatNumber ?? '-'}'),
                              avatar: const Icon(Icons.event_seat, size: 16),
                              backgroundColor: Colors.blue.shade50,
                            ),
                            Chip(
                              label: Text(_student?.seatType ?? 'Free Seat'),
                              avatar: const Icon(Icons.chair, size: 16),
                              backgroundColor: Colors.green.shade50,
                            ),
                            Chip(
                              label: Text(_student?.studyTime ?? ''),
                              avatar: const Icon(Icons.access_time, size: 16),
                              backgroundColor: Colors.orange.shade50,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Study stats
                  _SectionTitle('Study Statistics'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _StatCard(
                      label: 'Total Hours',
                      value: '${(_totalStudyMinutes / 60).toStringAsFixed(1)}h',
                      icon: Icons.timer,
                      color: Colors.purple,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _StatCard(
                      label: 'This Month',
                      value: '${(_thisMonthMinutes / 60).toStringAsFixed(1)}h',
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _StatCard(
                      label: 'Sessions',
                      value: '${_sessions.length}',
                      icon: Icons.play_circle,
                      color: Colors.green,
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Fee history
                  _SectionTitle('Fee History'),
                  const SizedBox(height: 8),
                  if (_fees.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No fee records', style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ...(_fees.map((fee) {
                      final statusColor = fee.paymentStatus == 'Paid' ? Colors.green : Colors.red;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.12),
                            child: Icon(Icons.receipt, color: statusColor, size: 20),
                          ),
                          title: Text(fee.plan, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Due: ${DateFormat('dd MMM yyyy').format(fee.dueDate)}', style: const TextStyle(fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(fee.paymentStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      );
                    })),
                  const SizedBox(height: 16),

                  // Personal info
                  _SectionTitle('Personal Information'),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        if (_student?.aadharNumber.isNotEmpty == true)
                          ListTile(
                            leading: const Icon(Icons.credit_card),
                            title: const Text('Aadhar Number'),
                            subtitle: Text(_student!.aadharNumber),
                          ),
                        if (_student?.birthday != null)
                          ListTile(
                            leading: const Icon(Icons.cake),
                            title: const Text('Birthday'),
                            subtitle: Text(DateFormat('dd MMMM yyyy').format(_student!.birthday!)),
                          ),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Joining Date'),
                          subtitle: Text(DateFormat('dd MMMM yyyy').format(_student?.joiningDate ?? DateTime.now())),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
