import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/attendance_model.dart';
import '../../../models/expense_model.dart';
import '../../../models/fee_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 29));
  DateTime _to = DateTime.now();
  bool _loading = true;

  List<StudentModel> _students = [];
  List<AttendanceModel> _attendance = [];
  List<FeeModel> _fees = [];
  List<ExpenseModel> _expenses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId == null) { setState(() => _loading = false); return; }
    setState(() => _loading = true);
    try {
      final students = await AppProviders.dbService.getStudents(libraryId);
      final attendance = await AppProviders.dbService.getAttendance(libraryId);
      final fees = await AppProviders.dbService.getFees(libraryId);
      final expenses = await AppProviders.dbService.getExpenses(libraryId);
      if (mounted) setState(() {
        _students = students;
        _attendance = attendance.where((a) => !a.timestamp.isBefore(_from) && !a.timestamp.isAfter(_to)).toList();
        _fees = fees.where((f) => !f.dueDate.isBefore(_from) && !f.dueDate.isAfter(_to)).toList();
        _expenses = expenses.where((e) => !e.date.isBefore(_from) && !e.date.isAfter(_to)).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  double get _totalRevenue => _fees.where((f) => f.paymentStatus == 'Paid').length *
      (context.read<LibraryProvider>().currentLibrary?.seatPrice ?? 0);
  double get _totalExpenses => _expenses.fold(0.0, (s, e) => s + e.amount);
  double get _netProfit => _totalRevenue - _totalExpenses;

  // Attendance by day for bar chart (last 7 days shown)
  Map<String, int> _attendanceByDay() {
    final map = <String, int>{};
    for (final a in _attendance) {
      if (a.status == 'Present') {
        final key = DateFormat('dd/MM').format(a.timestamp);
        map[key] = (map[key] ?? 0) + 1;
      }
    }
    return map;
  }

  // Expense by category for pie chart
  Map<String, double> _expenseByCategory() {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range != null) {
      setState(() { _from = range.start; _to = range.end; });
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceMap = _attendanceByDay();
    final expenseMap = _expenseByCategory();
    final catColors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Date range picker
                  InkWell(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3949AB).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.date_range, color: Color(0xFF3949AB)),
                        const SizedBox(width: 10),
                        Text(
                          '${DateFormat('dd MMM').format(_from)} – ${DateFormat('dd MMM yyyy').format(_to)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF3949AB)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(title: 'Total Students', value: '${_students.length}', icon: Icons.people, color: Colors.blue),
                      _StatCard(title: 'Total Revenue', value: '₹${_totalRevenue.toStringAsFixed(0)}', icon: Icons.currency_rupee, color: Colors.green),
                      _StatCard(title: 'Total Expenses', value: '₹${_totalExpenses.toStringAsFixed(0)}', icon: Icons.receipt, color: Colors.red),
                      _StatCard(title: 'Net Profit', value: '₹${_netProfit.toStringAsFixed(0)}', icon: Icons.trending_up, color: _netProfit >= 0 ? Colors.green : Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Attendance bar chart
                  if (attendanceMap.isNotEmpty) ...[
                    _SectionTitle(title: 'Daily Attendance (Present)'),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (attendanceMap.values.fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    final keys = attendanceMap.keys.toList();
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= keys.length) return const Text('');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(keys[idx], style: const TextStyle(fontSize: 9)),
                                    );
                                  },
                                  reservedSize: 28,
                                )),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: true, horizontalInterval: 2),
                              borderData: FlBorderData(show: false),
                              barGroups: attendanceMap.entries.toList().asMap().entries.map((e) {
                                return BarChartGroupData(x: e.key, barRods: [
                                  BarChartRodData(
                                    toY: e.value.value.toDouble(),
                                    color: const Color(0xFF3949AB),
                                    width: 14,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Expense pie chart
                  if (expenseMap.isNotEmpty) ...[
                    _SectionTitle(title: 'Expense Breakdown'),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 36,
                                  sections: expenseMap.entries.toList().asMap().entries.map((e) {
                                    final total = expenseMap.values.fold(0.0, (a, b) => a + b);
                                    return PieChartSectionData(
                                      value: e.value.value,
                                      color: catColors[e.key % catColors.length],
                                      title: '${(e.value.value / total * 100).toStringAsFixed(0)}%',
                                      titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                      radius: 45,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: expenseMap.entries.toList().asMap().entries.map((e) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(color: catColors[e.key % catColors.length], shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(e.value.key, style: const TextStyle(fontSize: 12))),
                                      Text('₹${e.value.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Icon(icon, size: 18, color: color),
            ]),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
}
