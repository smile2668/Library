import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/fee_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';
import '../../../utils/constants.dart';

class AdminFeesTab extends StatefulWidget {
  const AdminFeesTab({super.key});

  @override
  State<AdminFeesTab> createState() => _AdminFeesTabState();
}

class _AdminFeesTabState extends State<AdminFeesTab> {
  List<FeeModel> _fees = [];
  List<FeeModel> _filtered = [];
  List<StudentModel> _students = [];
  bool _loading = true;
  String? _planFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId == null) { setState(() => _loading = false); return; }
    try {
      final fees = await AppProviders.dbService.getFees(libraryId);
      final students = await AppProviders.dbService.getStudents(libraryId);
      if (mounted) {
        setState(() { _fees = fees; _students = students; _applyFilter(); _loading = false; });
      }
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  void _applyFilter() {
    _filtered = _planFilter == null
        ? List.from(_fees)
        : _fees.where((f) => f.plan == _planFilter).toList();
  }

  double get _totalCollected => _fees.where((f) => f.paymentStatus == 'Paid').length * (context.read<LibraryProvider>().currentLibrary?.seatPrice ?? 0);
  int get _pending => _fees.where((f) => f.paymentStatus == 'Pending').length;
  int get _overdue => _fees.where((f) => f.paymentStatus == 'Pending' && f.dueDate.isBefore(DateTime.now())).length;

  Future<void> _markPaid(FeeModel fee) async {
    try {
      await AppProviders.dbService.updateFee(fee.copyWith(paymentStatus: 'Paid'));
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as paid')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddFeeDialog() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AddFeeSheet(students: _students, onSaved: _load),
    );
  }

  Color _statusColor(FeeModel fee) {
    if (fee.paymentStatus == 'Paid') return Colors.green;
    if (fee.dueDate.isBefore(DateTime.now())) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _FeeStatCard(label: 'Collected', value: '₹${_totalCollected.toStringAsFixed(0)}', color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _FeeStatCard(label: 'Pending', value: '$_pending', color: Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _FeeStatCard(label: 'Overdue', value: '$_overdue', color: Colors.red)),
              ],
            ),
          ),
          // Plan filter
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(label: 'All', selected: _planFilter == null, onTap: () => setState(() { _planFilter = null; _applyFilter(); })),
                ...AppConstants.feePlans.map((p) => _FilterChip(
                  label: p,
                  selected: _planFilter == p,
                  onTap: () => setState(() { _planFilter = p; _applyFilter(); }),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Fee list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No fee records found'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final fee = _filtered[i];
                            final color = _statusColor(fee);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: color.withValues(alpha: 0.3)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color.withValues(alpha: 0.12),
                                      child: Icon(Icons.person, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(fee.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Seat ${fee.seatNumber} • ${fee.plan}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          Text('Due: ${DateFormat('dd MMM yyyy').format(fee.dueDate)}', style: TextStyle(fontSize: 12, color: color)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                          child: Text(fee.paymentStatus, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                        if (fee.paymentStatus != 'Paid') ...[
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            height: 30,
                                            child: TextButton(
                                              onPressed: () => _markPaid(fee),
                                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), foregroundColor: Colors.green),
                                              child: const Text('Mark Paid', style: TextStyle(fontSize: 12)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Fee'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _FeeStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _FeeStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF3949AB).withValues(alpha: 0.15),
        checkmarkColor: const Color(0xFF3949AB),
        side: BorderSide(color: selected ? const Color(0xFF3949AB) : Colors.grey.shade300),
      ),
    );
  }
}

class _AddFeeSheet extends StatefulWidget {
  final List<StudentModel> students;
  final VoidCallback onSaved;
  const _AddFeeSheet({required this.students, required this.onSaved});

  @override
  State<_AddFeeSheet> createState() => _AddFeeSheetState();
}

class _AddFeeSheetState extends State<_AddFeeSheet> {
  StudentModel? _selectedStudent;
  String _plan = AppConstants.feePlans[0];
  String _paymentMethod = 'Pay to counter';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  Future<void> _save() async {
    if (_selectedStudent == null) return;
    setState(() => _saving = true);
    try {
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      final fee = FeeModel(
        id: const Uuid().v4(),
        libraryId: libraryId,
        studentId: _selectedStudent!.id,
        studentName: _selectedStudent!.name,
        seatNumber: _selectedStudent!.seatNumber,
        plan: _plan,
        dueDate: _dueDate,
        paymentMethod: _paymentMethod,
        paymentStatus: 'Pending',
      );
      await AppProviders.dbService.addFee(fee);
      if (mounted) { Navigator.pop(context); widget.onSaved(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee record added'))); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add Fee Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<StudentModel>(
            decoration: _dec('Select Student *', Icons.person),
            items: widget.students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (v) => setState(() => _selectedStudent = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _plan,
            decoration: _dec('Plan', Icons.schedule),
            items: AppConstants.feePlans.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _plan = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: _dec('Payment Method', Icons.payment),
            items: ['Pay to counter', 'UPI', 'Online', 'Cash']
                .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('dd MMM yyyy').format(_dueDate)),
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _dueDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 400)));
              if (picked != null) setState(() => _dueDate = picked);
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3949AB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Fee Record'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true,
  );
}
