import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/library_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../utils/constants.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _mapsCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _totalSeatsCtrl;
  late TextEditingController _seatPriceCtrl;

  XFile? _logoFile;
  bool _saving = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    final library = context.read<LibraryProvider>().currentLibrary;
    _nameCtrl = TextEditingController(text: library?.name ?? '');
    _addressCtrl = TextEditingController(text: library?.address ?? '');
    _mapsCtrl = TextEditingController(text: library?.mapsLink ?? '');
    _websiteCtrl = TextEditingController(text: library?.websiteLink ?? '');
    _totalSeatsCtrl = TextEditingController(text: library?.totalSeats.toString() ?? '');
    _seatPriceCtrl = TextEditingController(text: library?.seatPrice.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _mapsCtrl.dispose();
    _websiteCtrl.dispose();
    _totalSeatsCtrl.dispose();
    _seatPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (f != null) setState(() => _logoFile = f);
  }

  Future<void> _saveLibrary() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final libraryProvider = context.read<LibraryProvider>();
      final existing = libraryProvider.currentLibrary!;
      String logoUrl = existing.logoUrl;
      if (_logoFile != null) {
        logoUrl = await AppProviders.storageService.uploadImage(
          bucket: AppConstants.bucketLibraryImages, path: '${existing.id}/logo.jpg', file: _logoFile!);
      }
      final updated = existing.copyWith(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        mapsLink: _mapsCtrl.text.trim(),
        websiteLink: _websiteCtrl.text.trim(),
        totalSeats: int.tryParse(_totalSeatsCtrl.text.trim()) ?? existing.totalSeats,
        seatPrice: double.tryParse(_seatPriceCtrl.text.trim()) ?? existing.seatPrice,
        logoUrl: logoUrl,
      );
      await libraryProvider.updateLibrary(updated);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Library updated successfully')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Library Logo
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _logoFile != null
                        ? FileImage(File(_logoFile!.path))
                        : (library?.logoUrl.isNotEmpty == true ? NetworkImage(library!.logoUrl) as ImageProvider : null),
                    child: (_logoFile == null && (library?.logoUrl.isEmpty ?? true))
                        ? const Icon(Icons.local_library, size: 48, color: Colors.grey)
                        : null,
                  ),
                  Positioned(bottom: 0, right: 0,
                    child: Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3949AB)),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white))),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'Library Information'),
            const SizedBox(height: 12),
            TextFormField(controller: _nameCtrl, decoration: _dec('Library Name *', Icons.business),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _addressCtrl, decoration: _dec('Address', Icons.location_on), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _mapsCtrl, decoration: _dec('Google Maps Link', Icons.map), keyboardType: TextInputType.url),
            const SizedBox(height: 12),
            TextFormField(controller: _websiteCtrl, decoration: _dec('Website Link', Icons.language), keyboardType: TextInputType.url),
            const SizedBox(height: 20),

            _SectionLabel(label: 'Seat Configuration'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _totalSeatsCtrl, decoration: _dec('Total Seats', Icons.event_seat), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _seatPriceCtrl, decoration: _dec('Seat Price (₹)', Icons.currency_rupee), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveLibrary,
                icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3949AB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'App Settings'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(value: _isDark, onChanged: (v) => setState(() => _isDark = v)),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: const Text('View QR Code'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'Account'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: _logout,
              ),
            ),
            const SizedBox(height: 20),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3949AB)));
}
