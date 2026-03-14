import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/student_provider.dart';
import 'tabs/admin_announcements_tab.dart';
import 'tabs/admin_attendance_tab.dart';
import 'tabs/admin_books_tab.dart';
import 'tabs/admin_expenses_tab.dart';
import 'tabs/admin_fees_tab.dart';
import 'tabs/admin_messages_tab.dart';
import 'tabs/admin_notes_tab.dart';
import 'tabs/admin_qr_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_seats_tab.dart';
import 'tabs/admin_settings_tab.dart';
import 'tabs/admin_staff_tab.dart';
import 'tabs/admin_students_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  bool _loadedData = false;

  // Tab configuration
  static const _tabs = [
    _TabConfig(icon: Icons.dashboard, label: 'Dashboard'),
    _TabConfig(icon: Icons.people, label: 'Students'),
    _TabConfig(icon: Icons.event_seat, label: 'Seats'),
    _TabConfig(icon: Icons.how_to_reg, label: 'Attendance'),
    _TabConfig(icon: Icons.payment, label: 'Fees'),
    _TabConfig(icon: Icons.menu_book, label: 'Books'),
    _TabConfig(icon: Icons.receipt_long, label: 'Expenses'),
    _TabConfig(icon: Icons.badge, label: 'Staff'),
    _TabConfig(icon: Icons.note, label: 'Notes'),
    _TabConfig(icon: Icons.message, label: 'Messages'),
    _TabConfig(icon: Icons.campaign, label: 'Announcements'),
    _TabConfig(icon: Icons.bar_chart, label: 'Reports'),
    _TabConfig(icon: Icons.settings, label: 'Settings'),
    _TabConfig(icon: Icons.qr_code, label: 'QR Code'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    if (_loadedData) return;
    _loadedData = true;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<LibraryProvider>().fetchLibrary(userId);
    }
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId != null) {
      await context.read<StudentProvider>().fetchStudents(libraryId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final library = context.watch<LibraryProvider>().currentLibrary;
    final students = context.watch<StudentProvider>().students;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            if (library?.logoUrl.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(library!.logoUrl),
                  backgroundColor: Colors.white24,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.local_library, size: 24),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    library?.name ?? 'Admin Dashboard',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _tabs[_selectedTab].label,
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            color: const Color(0xFF1A237E),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 3),
              ),
              tabs: _tabs.map((t) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon, size: 16),
                    const SizedBox(width: 6),
                    Text(t.label),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DashboardTab(library: library, students: students),
          const AdminStudentsTab(),
          const AdminSeatsTab(),
          const AdminAttendanceTab(),
          const AdminFeesTab(),
          const AdminBooksTab(),
          const AdminExpensesTab(),
          const AdminStaffTab(),
          const AdminNotesTab(),
          const AdminMessagesTab(),
          const AdminAnnouncementsTab(),
          const AdminReportsTab(),
          const AdminSettingsTab(),
          const AdminQrTab(),
        ],
      ),
    );
  }
}

// ── Dashboard Tab ──────────────────────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  final dynamic library;
  final List students;
  const _DashboardTab({required this.library, required this.students});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  double _monthlyRevenue = 0;
  bool _loadingRevenue = true;

  @override
  void initState() {
    super.initState();
    _loadRevenue();
  }

  Future<void> _loadRevenue() async {
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId == null) { setState(() => _loadingRevenue = false); return; }
    try {
      final fees = await AppProviders.dbService.getFees(libraryId);
      final now = DateTime.now();
      final monthlyPaid = fees.where((f) =>
        f.paymentStatus == 'Paid' &&
        f.dueDate.year == now.year &&
        f.dueDate.month == now.month
      ).length;
      if (mounted) setState(() {
        _monthlyRevenue = monthlyPaid * (widget.library?.seatPrice ?? 0);
        _loadingRevenue = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRevenue = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    final totalSeats = library?.totalSeats ?? 0;
    final freeSeats = library?.freeSeats ?? 0;
    final occupiedSeats = totalSeats - freeSeats;
    final studentCount = widget.students.length;

    return RefreshIndicator(
      onRefresh: _loadRevenue,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Good Day! 👋', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(library?.name ?? 'Your Library', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(library?.address ?? '', style: const TextStyle(color: Colors.white60, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  backgroundImage: library?.logoUrl.isNotEmpty == true ? NetworkImage(library!.logoUrl) : null,
                  child: library?.logoUrl.isEmpty != false
                      ? const Icon(Icons.local_library, color: Colors.white, size: 28)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _DashCard(label: 'Total Seats', value: '$totalSeats', icon: Icons.event_seat, color: Colors.blue),
              _DashCard(label: 'Free Seats', value: '$freeSeats', icon: Icons.chair_outlined, color: Colors.green),
              _DashCard(label: 'Students', value: '$studentCount', icon: Icons.people, color: Colors.orange),
              _DashCard(
                label: 'Monthly Revenue',
                value: _loadingRevenue ? '...' : '₹${_monthlyRevenue.toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Occupancy progress
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Seat Occupancy', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        totalSeats > 0 ? '${(occupiedSeats / totalSeats * 100).toStringAsFixed(0)}%' : '0%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3949AB)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalSeats > 0 ? occupiedSeats / totalSeats : 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF3949AB)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LegendItem(color: const Color(0xFF3949AB), label: 'Occupied: $occupiedSeats'),
                      _LegendItem(color: Colors.green, label: 'Free: $freeSeats'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          const Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _QuickActionButton(icon: Icons.person_add, label: 'Add Student', color: Colors.blue, onTap: () {})),
            const SizedBox(width: 8),
            Expanded(child: _QuickActionButton(icon: Icons.campaign, label: 'Announce', color: Colors.purple, onTap: () {})),
            const SizedBox(width: 8),
            Expanded(child: _QuickActionButton(icon: Icons.qr_code, label: 'Show QR', color: Colors.teal, onTap: () {})),
            const SizedBox(width: 8),
            Expanded(child: _QuickActionButton(icon: Icons.bar_chart, label: 'Reports', color: Colors.orange, onTap: () {})),
          ]),
        ],
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _DashCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, size: 18, color: color),
              ],
            ),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TabConfig {
  final IconData icon;
  final String label;
  const _TabConfig({required this.icon, required this.label});
}
