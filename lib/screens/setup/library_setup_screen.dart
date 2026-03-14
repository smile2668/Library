import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/library_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../utils/constants.dart';

class LibrarySetupScreen extends StatefulWidget {
  const LibrarySetupScreen({super.key});

  @override
  State<LibrarySetupScreen> createState() => _LibrarySetupScreenState();
}

class _LibrarySetupScreenState extends State<LibrarySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _mapsCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _totalSeatsCtrl = TextEditingController(text: '50');
  final _seatPriceCtrl = TextEditingController();

  XFile? _logoFile;
  List<XFile> _libraryImages = [];
  bool _saving = false;
  int _currentStep = 0;

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
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) setState(() => _logoFile = f);
  }

  Future<void> _pickLibraryImages() async {
    if (_libraryImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed')));
      return;
    }
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (f != null) setState(() => _libraryImages.add(f));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) { setState(() => _currentStep = 0); return; }
    setState(() => _saving = true);
    try {
      final userId = context.read<AuthProvider>().currentUser!.id;
      final libraryId = const Uuid().v4();

      // Upload logo
      String logoUrl = '';
      if (_logoFile != null) {
        logoUrl = await AppProviders.storageService.uploadImage(
          bucket: AppConstants.bucketLibraryImages, path: '$libraryId/logo.jpg', file: _logoFile!);
      }

      // Upload library images
      final imageUrls = <String>[];
      for (int i = 0; i < _libraryImages.length; i++) {
        final url = await AppProviders.storageService.uploadImage(
          bucket: AppConstants.bucketLibraryImages, path: '$libraryId/image_\${i}.jpg', file: _libraryImages[i]);
        imageUrls.add(url);
      }

      final library = LibraryModel(
        id: libraryId,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        mapsLink: _mapsCtrl.text.trim(),
        websiteLink: _websiteCtrl.text.trim(),
        totalSeats: int.tryParse(_totalSeatsCtrl.text.trim()) ?? 50,
        freeSeats: int.tryParse(_totalSeatsCtrl.text.trim()) ?? 50,
        seatPrice: double.tryParse(_seatPriceCtrl.text.trim()) ?? 0,
        adminId: userId,
        logoUrl: logoUrl,
        imageUrls: imageUrls,
      );

      await context.read<LibraryProvider>().saveLibrary(library);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Library created successfully!')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Library'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) setState(() => _currentStep++);
            else _save();
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (ctx, controls) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(children: [
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : controls.onStepContinue,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3949AB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_currentStep == 2 ? 'Create Library' : 'Continue'),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: controls.onStepCancel,
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ]),
          ),
          steps: [
            Step(
              title: const Text('Basic Info'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickLogo,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _logoFile != null ? FileImage(File(_logoFile!.path)) : null,
                            child: _logoFile == null ? const Icon(Icons.local_library, size: 40, color: Colors.grey) : null,
                          ),
                          const SizedBox(height: 8),
                          Text('Upload Logo', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _dec('Library Name *', Icons.business),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: _dec('Address *', Icons.location_on),
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Links & Pricing'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(controller: _mapsCtrl, decoration: _dec('Google Maps Link', Icons.map), keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  TextFormField(controller: _websiteCtrl, decoration: _dec('Website Link', Icons.language), keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: _totalSeatsCtrl,
                      decoration: _dec('Total Seats', Icons.event_seat),
                      keyboardType: TextInputType.number,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(
                      controller: _seatPriceCtrl,
                      decoration: _dec('Monthly Price (₹)', Icons.currency_rupee),
                      keyboardType: TextInputType.number,
                    )),
                  ]),
                ],
              ),
            ),
            Step(
              title: const Text('Library Images'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add up to 5 photos of your library (optional)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      ..._libraryImages.asMap().entries.map((e) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(e.value.path), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => _libraryImages.removeAt(e.key)),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                      if (_libraryImages.length < 5)
                        GestureDetector(
                          onTap: _pickLibraryImages,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, color: Colors.grey, size: 28),
                                Text('Add', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
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
