import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/book_request_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../utils/constants.dart';

class StudentBooksTab extends StatefulWidget {
  const StudentBooksTab({super.key});

  @override
  State<StudentBooksTab> createState() => _StudentBooksTabState();
}

class _StudentBooksTabState extends State<StudentBooksTab> {
  List<BookRequestModel> _myBooks = [];
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
      final books = await AppProviders.dbService.getBooks(libraryId);
      final myBooks = books.where((b) => b.studentId == userId).toList();
      if (mounted) setState(() { _myBooks = myBooks; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  void _showRequestForm() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _RequestBookSheet(onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _myBooks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No book requests yet'),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: _showRequestForm,
                            icon: const Icon(Icons.add),
                            label: const Text('Request a Book'),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE64A19)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _myBooks.length,
                      itemBuilder: (ctx, i) {
                        final book = _myBooks[i];
                        final statusColor = _statusColor(book.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: book.imageUrl.isNotEmpty
                                  ? Image.network(book.imageUrl, width: 52, height: 52, fit: BoxFit.cover)
                                  : Container(
                                      width: 52, height: 52,
                                      color: Colors.blue.shade50,
                                      child: const Icon(Icons.menu_book, color: Colors.blue),
                                    ),
                            ),
                            title: Text(book.bookName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Book Request', style: TextStyle(fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                book.status,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestForm,
        icon: const Icon(Icons.add),
        label: const Text('Request Book'),
        backgroundColor: const Color(0xFFE64A19),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _RequestBookSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _RequestBookSheet({required this.onSaved});

  @override
  State<_RequestBookSheet> createState() => _RequestBookSheetState();
}

class _RequestBookSheetState extends State<_RequestBookSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameCtrl = TextEditingController();
  XFile? _imageFile;
  bool _saving = false;

  @override
  void dispose() {
    _bookNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (f != null) setState(() => _imageFile = f);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final userId = context.read<AuthProvider>().currentUser!.id;
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      String imageUrl = '';
      if (_imageFile != null) {
        final id = const Uuid().v4();
        imageUrl = await AppProviders.storageService.uploadImage(
          bucket: AppConstants.bucketBookImages, path: '$id/cover.jpg', file: _imageFile!);
      }
      final book = BookRequestModel(
        id: const Uuid().v4(),
        libraryId: libraryId,
        studentId: userId,
        bookName: _bookNameCtrl.text.trim(),
        imageUrl: imageUrl,
        status: 'Pending',
      );
      await AppProviders.dbService.addBook(book);
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book request submitted')));
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
              const Text('Request a Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bookNameCtrl,
              decoration: InputDecoration(
                labelText: 'Book Name *',
                prefixIcon: const Icon(Icons.menu_book),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imageFile != null ? 'Image selected ✓' : 'Add Book Cover Image (optional)'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_imageFile!.path), height: 80, width: 80, fit: BoxFit.cover),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE64A19), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Request'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
