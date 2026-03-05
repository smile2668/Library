import 'package:flutter/material.dart';

import '../../widgets/metric_card.dart';
import 'tabs/admin_attendance_tab.dart';
import 'tabs/admin_books_tab.dart';
import 'tabs/admin_fees_tab.dart';
import 'tabs/admin_seats_tab.dart';
import 'tabs/admin_settings_tab.dart';
import 'tabs/admin_students_tab.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Seats'),
              Tab(text: 'Attendance'),
              Tab(text: 'Fees'),
              Tab(text: 'Books'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 2,
                children: const [
                  MetricCard(title: 'Total Seats', value: '100'),
                  MetricCard(title: 'Free Seats', value: '27'),
                  MetricCard(title: 'Occupied Seats', value: '73'),
                  MetricCard(title: 'Pending Fees', value: '12'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AdminStudentsTab(),
                  AdminSeatsTab(),
                  AdminAttendanceTab(),
                  AdminFeesTab(),
                  AdminBooksTab(),
                  AdminSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
