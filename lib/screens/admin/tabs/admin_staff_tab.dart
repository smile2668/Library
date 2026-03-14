import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/staff_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';
import '../../../utils/constants.dart';

class AdminStaffTab extends StatefulWidget {
  const AdminStaffTab({super.key});

  @override
  State<AdminStaffTab> createState() => _AdminStaffTabState();
}

class _AdminStaffTabState extends State<AdminStaffTab> {
  List<StaffModel> _staff = [];
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
      final staff = await AppProviders.dbService.getStaff(libraryId);
      if (mounted) setState(() { _staff = staff; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  Future<void> _deleteStaff(StaffModel staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Staff'),
        content: Text('Remove ${staff.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AppProviders.dbService.deleteStaff(staff.id);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff removed')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showForm([StaffModel? existing]) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _StaffFormSheet(existing: existing, onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _staff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.badge_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No staff members yet'),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () => _showForm(),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Staff'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _staff.length,
                    itemBuilder: (ctx, i) {
                      final s = _staff[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.teal.shade100,
                            backgroundImage: s.photoUrl.isNotEmpty ? NetworkImage(s.photoUrl) : null,
                            child: s.photoUrl.isEmpty
                                ? Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700))
                                : null,
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📱 ${s.phone}', style: const TextStyle(fontSize: 12)),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20)),
                                  child: Text(s.role.toUpperCase(), style: TextStyle(fontSize: 11, color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                                ),
                              ]),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _showForm(s);
                              if (v == 'delete') _deleteStaff(s);
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Remove', style: TextStyle(color: Colors.red)))),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StaffFormSheet extends StatefulWidget {
  final StaffModel? existing;
  final VoidCallback onSaved;
  const _StaffFormSheet({this.existing, required this.onSaved});

  @override
  State<_StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<_StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String _role = AppConstants.roleStaff;
  XFile? _photoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
    _role = widget.existing?.role ?? AppConstants.roleStaff;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (f != null) setState(() => _photoFile = f);
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
          AppConstants.bucketStudentPhotos, 'staff/$id/photo.jpg', _photoFile!);
      }
      final staff = StaffModel(
        id: widget.existing?.id ?? const Uuid().v4(),
        libraryId: libraryId,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _role,
        photoUrl: photoUrl,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );
      if (widget.existing != null) {
        await AppProviders.dbService.updateStaff(staff);
      } else {
        await AppProviders.dbService.addStaff(staff);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing != null ? 'Staff updated' : 'Staff added')));
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Text(widget.existing != null ? 'Edit Staff' : 'Add Staff',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _photoFile != null ? FileImage(File(_photoFile!.path)) : null,
                    child: _photoFile == null ? const Icon(Icons.person, size: 36, color: Colors.grey) : null,
                  ),
                  Positioned(bottom: 0, right: 0,
                    child: Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.teal),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white))),
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
              controller: _phoneCtrl,
              decoration: _dec('Phone Number *', Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: _dec('Role', Icons.badge),
              items: [AppConstants.roleStaff, AppConstants.roleAdmin]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : Text(widget.existing != null ? 'Update' : 'Add Staff'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true,
  );
}
