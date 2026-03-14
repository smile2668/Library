import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/message_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';

class AdminMessagesTab extends StatefulWidget {
  const AdminMessagesTab({super.key});

  @override
  State<AdminMessagesTab> createState() => _AdminMessagesTabState();
}

class _AdminMessagesTabState extends State<AdminMessagesTab> {
  List<MessageModel> _messages = [];
  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
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
      final messages = await AppProviders.dbService.getMessages(libraryId);
      final students = await AppProviders.dbService.getStudents(libraryId);
      if (mounted) setState(() { _messages = messages; _students = students; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  List<MessageModel> get _currentMessages {
    if (_selectedStudent == null) {
      return _messages.where((m) => m.receiverId == null).toList();
    }
    return _messages
        .where((m) => m.receiverId == _selectedStudent!.id || m.senderId == _selectedStudent!.id)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _showComposeDialog() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ComposeMessageSheet(students: _students, onSent: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar: student list
          Container(
            width: 220,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('All / Broadcast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  leading: const CircleAvatar(child: Icon(Icons.campaign, size: 18)),
                  selected: _selectedStudent == null,
                  selectedTileColor: const Color(0xFF3949AB).withValues(alpha: 0.08),
                  onTap: () => setState(() => _selectedStudent = null),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (ctx, i) {
                            final s = _students[i];
                            final unread = _messages.where((m) => m.receiverId == s.id && !m.isRead).length;
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundImage: s.photoUrl.isNotEmpty ? NetworkImage(s.photoUrl) : null,
                                child: s.photoUrl.isEmpty ? Text(s.name[0], style: const TextStyle(fontSize: 12)) : null,
                              ),
                              title: Text(s.name, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('Seat ${s.seatNumber}', style: const TextStyle(fontSize: 11)),
                              selected: _selectedStudent?.id == s.id,
                              selectedTileColor: const Color(0xFF3949AB).withValues(alpha: 0.08),
                              trailing: unread > 0 ? CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white))) : null,
                              onTap: () => setState(() => _selectedStudent = s),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Message thread
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF3949AB).withValues(alpha: 0.06),
                  child: Row(
                    children: [
                      Text(
                        _selectedStudent?.name ?? 'Broadcast to All',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Refresh'),
                    ],
                  ),
                ),
                // Messages
                Expanded(
                  child: _currentMessages.isEmpty
                      ? const Center(child: Text('No messages yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _currentMessages.length,
                          itemBuilder: (ctx, i) {
                            final msg = _currentMessages[i];
                            final isAdmin = msg.senderId == context.read<AuthProvider>().currentUser?.id;
                            return _MessageBubble(message: msg, isMe: isAdmin);
                          },
                        ),
                ),
                // Compose bar
                _ComposeBar(
                  receiverId: _selectedStudent?.id,
                  onSent: _load,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showComposeDialog,
        icon: const Icon(Icons.edit),
        label: const Text('New Message'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF3949AB) : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposeBar extends StatefulWidget {
  final String? receiverId;
  final VoidCallback onSent;
  const _ComposeBar({this.receiverId, required this.onSent});

  @override
  State<_ComposeBar> createState() => _ComposeBarState();
}

class _ComposeBarState extends State<_ComposeBar> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      final senderId = context.read<AuthProvider>().currentUser!.id;
      final msg = MessageModel(
        id: const Uuid().v4(),
        libraryId: libraryId,
        senderId: senderId,
        receiverId: widget.receiverId,
        content: content,
        createdAt: DateTime.now(),
      );
      await AppProviders.dbService.addMessage(msg);
      _ctrl.clear();
      widget.onSent();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: widget.receiverId != null ? 'Message student...' : 'Broadcast to all students...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              maxLines: null,
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _sending ? null : _send,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3949AB),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: _sending
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ComposeMessageSheet extends StatefulWidget {
  final List<StudentModel> students;
  final VoidCallback onSent;
  const _ComposeMessageSheet({required this.students, required this.onSent});

  @override
  State<_ComposeMessageSheet> createState() => _ComposeMessageSheetState();
}

class _ComposeMessageSheetState extends State<_ComposeMessageSheet> {
  StudentModel? _to;
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      final senderId = context.read<AuthProvider>().currentUser!.id;
      final msg = MessageModel(
        id: const Uuid().v4(), libraryId: libraryId,
        senderId: senderId, receiverId: _to?.id,
        content: content, createdAt: DateTime.now(),
      );
      await AppProviders.dbService.addMessage(msg);
      if (mounted) {
        Navigator.pop(context);
        widget.onSent();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
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
          Row(children: [
            const Text('New Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<StudentModel?>(
            value: _to,
            decoration: InputDecoration(labelText: 'To', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true),
            items: [
              const DropdownMenuItem<StudentModel?>(value: null, child: Text('All Students (Broadcast)')),
              ...widget.students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
            ],
            onChanged: (v) => setState(() => _to = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _msgCtrl,
            decoration: InputDecoration(labelText: 'Message', prefixIcon: const Icon(Icons.message), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sending ? null : _send,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3949AB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Message'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
