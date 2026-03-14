import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../models/note_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';

class AdminNotesTab extends StatefulWidget {
  const AdminNotesTab({super.key});

  @override
  State<AdminNotesTab> createState() => _AdminNotesTabState();
}

class _AdminNotesTabState extends State<AdminNotesTab> {
  List<NoteModel> _notes = [];
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
      final notes = await AppProviders.dbService.getNotes(libraryId);
      if (mounted) setState(() { _notes = notes; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  Future<void> _deleteNote(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${note.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AppProviders.dbService.deleteNote(note.id);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openNote(NoteModel note) async {
    if (note.fileUrl.isEmpty) return;
    final uri = Uri.tryParse(note.fileUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddNote() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AddNoteSheet(onSaved: _load),
    );
  }

  IconData _fileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc':
      case 'docx': return Icons.description;
      case 'ppt':
      case 'pptx': return Icons.slideshow;
      case 'xls':
      case 'xlsx': return Icons.table_chart;
      default: return Icons.insert_drive_file;
    }
  }

  Color _fileColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf': return Colors.red;
      case 'doc':
      case 'docx': return Colors.blue;
      case 'ppt':
      case 'pptx': return Colors.orange;
      case 'xls':
      case 'xlsx': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No notes uploaded yet'),
                      const SizedBox(height: 8),
                      FilledButton.icon(onPressed: _showAddNote, icon: const Icon(Icons.upload_file), label: const Text('Upload Note')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (ctx, i) {
                      final note = _notes[i];
                      final fileColor = _fileColor(note.fileType);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: fileColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_fileIcon(note.fileType), color: fileColor, size: 28),
                          ),
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.fileType.toUpperCase(), style: TextStyle(color: fileColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(DateFormat('dd MMM yyyy').format(note.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 20),
                                onPressed: () => _openNote(note),
                                tooltip: 'Open',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                onPressed: () => _deleteNote(note),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNote,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Note'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddNoteSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddNoteSheet({required this.onSaved});

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String _fileType = 'pdf';
  bool _saving = false;

  static const _fileTypes = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'other'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      final uploadedBy = context.read<AuthProvider>().currentUser!.id;
      final note = NoteModel(
        id: const Uuid().v4(),
        libraryId: libraryId,
        title: _titleCtrl.text.trim(),
        fileUrl: _urlCtrl.text.trim(),
        fileType: _fileType,
        uploadedBy: uploadedBy,
        createdAt: DateTime.now(),
      );
      await AppProviders.dbService.addNote(note);
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note uploaded')));
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
              const Text('Upload Note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: _dec('Note Title *', Icons.title),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlCtrl,
              decoration: _dec('File URL (Google Drive / direct link)', Icons.link),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fileType,
              decoration: _dec('File Type', Icons.insert_drive_file),
              items: _fileTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _fileType = v!),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3949AB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Note'),
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
