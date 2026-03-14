import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/message_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/library_provider.dart';

class StudentMessagesTab extends StatefulWidget {
  const StudentMessagesTab({super.key});

  @override
  State<StudentMessagesTab> createState() => _StudentMessagesTabState();
}

class _StudentMessagesTabState extends State<StudentMessagesTab> {
  List<MessageModel> _messages = [];
  bool _loading = true;
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (userId == null || libraryId == null) { setState(() => _loading = false); return; }
    try {
      final all = await AppProviders.dbService.getMessages(libraryId);
      // Show broadcast messages (receiverId null) and messages to/from this student
      final myMessages = all.where((m) =>
          m.receiverId == null ||
          m.receiverId == userId ||
          m.senderId == userId
      ).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (mounted) setState(() { _messages = myMessages; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); }
    }
  }

  Future<void> _sendReply() async {
    final content = _replyCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      final userId = context.read<AuthProvider>().currentUser!.id;
      final libraryId = context.read<LibraryProvider>().currentLibrary!.id;
      final msg = MessageModel(
        id: const Uuid().v4(),
        libraryId: libraryId,
        senderId: userId,
        receiverId: null, // send to admin (no specific receiver means admin will see it)
        content: content,
        createdAt: DateTime.now(),
      );
      await AppProviders.dbService.addMessage(msg);
      _replyCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE64A19).withValues(alpha: 0.06),
            child: Row(
              children: [
                const Icon(Icons.message, color: Color(0xFFE64A19)),
                const SizedBox(width: 10),
                const Text('Messages from Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No messages yet', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == userId;
                          return _MessageBubble(message: msg, isMe: isMe);
                        },
                      ),
          ),
          // Reply bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    decoration: InputDecoration(
                      hintText: 'Send a message to admin...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendReply(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sending ? null : _sendReply,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE64A19),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: _sending
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE64A19) : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.receiverId == null ? '📢 Broadcast' : 'Admin',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
            Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a • dd MMM').format(message.createdAt),
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
