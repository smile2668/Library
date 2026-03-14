import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/student_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';
import '../../../utils/constants.dart';

class AdminStudentsTab extends StatefulWidget {
  const AdminStudentsTab({super.key});

  @override
  State<AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends State<AdminStudentsTab> {
  List<StudentModel> _students = [];
  List<StudentModel> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final students = await AppProviders.dbService.getStudents(libraryId);
      if (mounted) setState(() { _students = students; _applyFilter(); _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _applyFilter() {
    _filtered = _search.isEmpty
        ? List.from(_students)
        : _students.where((s) =>
            s.name.toLowerCase().contains(_search.toLowerCase()) ||
            s.mobile.contains(_search) ||
            s.seatNumber.toString().contains(_search)).toList();
  }

  Future<void> _deleteStudent(StudentModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Delete ${student.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AppProviders.dbService.deleteStudent(student.id);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showStudentForm([StudentModel? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _StudentFormSheet(
        existing: existing,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, mobile or seat...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                isDense: true,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() { _search = ''; _applyFilter(); }),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('${_filtered.length} students',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No students found'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final s = _filtered[i];
                            return _StudentCard(
                              student: s,
                              onEdit: () => _showStudentForm(s),
                              onDelete: () => _deleteStudent(s),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentCard({required this.student, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF3949AB).withValues(alpha: 0.12),
          backgroundImage: student.photoUrl.isNotEmpty ? NetworkImage(student.photoUrl) : null,
          child: student.photoUrl.isEmpty
              ? Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3949AB)),
                )
              : null,
        ),
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📱 ${student.mobile} • Seat ${student.seatNumber}', style: const TextStyle(fontSize: 12)),
            Text('${student.seatType} • ${student.studyTime}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _StudentFormSheet extends StatefulWidget {
  final StudentModel? existing;
  final VoidCallback onSaved;

  const _StudentFormSheet({this.existing, required this.onSaved});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _seatCtrl;
  late final TextEditingController _aadharCtrl;

  String _seatType = 'Free Seat';
  String _studyTime = AppConstants.studyTimes[3];
  DateTime _joiningDate = DateTime.now();
  DateTime? _birthday;
  File? _photoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _mobileCtrl = TextEditingController(text: s?.mobile ?? '');
    _seatCtrl = TextEditingController(text: s?.seatNumber != null ? '${s!.seatNumber}' : '');
    _aadharCtrl = TextEditingController(text: s?.aadharNumber ?? '');
    _seatType = s?.seatType ?? 'Free Seat';
    _studyTime = s?.studyTime ?? AppConstants.studyTimes[3];
    _joiningDate = s?.joiningDate ?? DateTime.now();
    _birthday = s?.birthday;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _seatCtrl.dispose();
    _aadharCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (f != null) setState(() => _photoFile = File(f.path));
  }

  Future<void> _pickDate({required bool isBirthday}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthday ? (_birthday ?? DateTime(2000)) : _joiningDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isBirthday) _birthday = picked;
        else _joiningDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      String photoUrl = widget.existing?.photoUrl ?? '';
      if (_photoFile != null) {
        final id = widget.existing?.id ?? const Uuid().v4();
        photoUrl = await AppProviders.storageService.uploadImage(
          AppConstants.bucketStudentPhotos, '$id/photo.jpg', _photoFile!);
      }
      final student = StudentModel(
        id: widget.existing?.id ?? const Uuid().v4(),
        libraryId: libraryId,
        name: _nameCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        seatNumber: int.tryParse(_seatCtrl.text.trim()) ?? 0,
        seatType: _seatType,
        studyTime: _studyTime,
        joiningDate: _joiningDate,
        birthday: _birthday,
        photoUrl: photoUrl,
        aadharNumber: _aadharCtrl.text.trim(),
      );
      if (widget.existing != null) {
        await AppProviders.dbService.updateStudent(student);
      } else {
        await AppProviders.dbService.addStudent(student);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing != null ? 'Student updated' : 'Student added')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(widget.existing != null ? 'Edit Student' : 'Add Student',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Photo
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Stack(children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _photoFile != null ? FileImage(_photoFile!) : null,
                            child: _photoFile == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                          ),
                          Positioned(bottom: 0, right: 0,
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3949AB)),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            )),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _dec('Full Name *', Icons.person),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mobileCtrl,
                      decoration: _dec('Mobile Number *', Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _seatCtrl,
                      decoration: _dec('Seat Number *', Icons.event_seat),
                      keyboardType: TextInputType.number,
                      validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _seatType,
                      decoration: _dec('Seat Type', Icons.chair),
                      items: ['Free Seat', 'Fixed Seat']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _seatType = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _studyTime,
                      decoration: _dec('Study Time', Icons.access_time),
                      items: AppConstants.studyTimes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _studyTime = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _aadharCtrl,
                      decoration: _dec('Aadhar Number', Icons.credit_card),
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Joining Date'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(_joiningDate)),
                      onTap: () => _pickDate(isBirthday: false),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cake),
                      title: const Text('Birthday (optional)'),
                      subtitle: Text(_birthday != null ? DateFormat('dd MMM yyyy').format(_birthday!) : 'Not set'),
                      onTap: () => _pickDate(isBirthday: true),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3949AB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: _saving ? const CircularProgressIndicator(color: Colors.white) : Text(widget.existing != null ? 'Update Student' : 'Add Student', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    isDense: true,
  );
}
