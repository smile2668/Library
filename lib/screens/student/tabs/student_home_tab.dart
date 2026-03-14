import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/announcement_model.dart';
import '../../../models/fee_model.dart';
import '../../../models/student_model.dart';
import '../../../models/study_session_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../widgets/announcement_banner.dart';
import '../../../widgets/study_timer_widget.dart';

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  StudentModel? _student;
  List<AnnouncementModel> _announcements = [];
  List<FeeModel> _fees = [];
  StudySessionModel? _activeSession;
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
      final announcements = await AppProviders.dbService.getAnnouncements(libraryId);
      final fees = await AppProviders.dbService.getFees(libraryId);
      final myFees = fees.where((f) => f.studentId == userId).toList();
      final sessions = await AppProviders.dbService.getStudySessions(libraryId);
      final activeSession = sessions.where((s) => s.studentId == userId && s.isActive).firstOrNull;
      if (mounted) setState(() {
        _student = student;
        _announcements = announcements;
        _fees = myFees;
        _activeSession = activeSession;
        _loading = false;
      });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); }
    }
  }

  FeeModel? get _latestFee => _fees.isEmpty ? null : (_fees..sort((a, b) => b.dueDate.compareTo(a.dueDate))).first;
  bool get _feeOverdue => _latestFee != null && _latestFee!.paymentStatus != 'Paid' && _latestFee!.dueDate.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Announcements banner
                if (_announcements.isNotEmpty) ...[
                  AnnouncementBanner(announcements: _announcements),
                  const SizedBox(height: 16),
                ],

                // Student greeting
                if (_student != null) ...[
                  Text(
                    'Hello, ${_student!.name.split(' ').first}! 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Seat ${_student!.seatNumber} • ${_student!.seatType}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                ],

                // Fee status card
                if (_latestFee != null)
                  Card(
                    color: _feeOverdue ? Colors.red.shade50 : Colors.green.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: Icon(
                        _feeOverdue ? Icons.warning_amber : Icons.check_circle,
                        color: _feeOverdue ? Colors.red : Colors.green,
                        size: 28,
                      ),
                      title: Text(
                        _feeOverdue ? 'Fee Overdue!' : 'Fee Status: ${_latestFee!.paymentStatus}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _feeOverdue ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                      subtitle: Text('Plan: ${_latestFee!.plan} • Due: ${_latestFee!.dueDate.day}/${_latestFee!.dueDate.month}/${_latestFee!.dueDate.year}'),
                    ),
                  ),
                const SizedBox(height: 16),

                // Study timer
                StudyTimerWidget(
                  studentId: userId,
                  libraryId: context.read<LibraryProvider>().currentLibrary?.id ?? '',
                  activeSession: _activeSession,
                  onSessionChanged: _load,
                ),
                const SizedBox(height: 16),

                // Quick stats
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _QuickStatCard(label: 'My Seat', value: '${_student?.seatNumber ?? '-'}', icon: Icons.event_seat, color: Colors.blue),
                    _QuickStatCard(label: 'Study Time', value: _student?.studyTime ?? '-', icon: Icons.access_time, color: Colors.orange),
                    _QuickStatCard(label: 'Fee Status', value: _latestFee?.paymentStatus ?? 'No Record', icon: Icons.payment, color: Colors.purple),
                    _QuickStatCard(label: 'Announcements', value: '${_announcements.length}', icon: Icons.campaign, color: Colors.red),
                  ],
                ),
              ],
            ),
          );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
