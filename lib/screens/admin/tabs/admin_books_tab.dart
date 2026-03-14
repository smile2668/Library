import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/book_request_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/library_provider.dart';

class AdminBooksTab extends StatefulWidget {
  const AdminBooksTab({super.key});

  @override
  State<AdminBooksTab> createState() => _AdminBooksTabState();
}

class _AdminBooksTabState extends State<AdminBooksTab> {
  List<BookRequestModel> _books = [];
  List<BookRequestModel> _filtered = [];
  bool _loading = true;
  String _statusFilter = 'All';

  static const _statuses = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final libraryId = context.read<LibraryProvider>().currentLibrary?.id;
    if (libraryId == null) { setState(() => _loading = false); return; }
    try {
      final books = await AppProviders.dbService.getBooks(libraryId);
      if (mounted) { setState(() { _books = books; _applyFilter(); _loading = false; }); }
    } catch (e) {
      if (mounted) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  void _applyFilter() {
    _filtered = _statusFilter == 'All' ? List.from(_books) : _books.where((b) => b.status == _statusFilter).toList();
  }

  Future<void> _updateStatus(BookRequestModel book, String status) async {
    try {
      await AppProviders.dbService.updateBook(book.copyWith(status: status));
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request $status')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: _statuses.skip(1).map((s) {
                final count = _books.where((b) => b.status == s).length;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _statusColor(s))),
                            Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Filter chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _statuses.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s),
                  selected: _statusFilter == s,
                  onSelected: (_) => setState(() { _statusFilter = s; _applyFilter(); }),
                  selectedColor: const Color(0xFF3949AB).withValues(alpha: 0.15),
                  checkmarkColor: const Color(0xFF3949AB),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Books list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No book requests found'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final book = _filtered[i];
                            final statusColor = _statusColor(book.status);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    // Book image / icon
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: book.imageUrl.isNotEmpty
                                          ? Image.network(book.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                                          : Container(
                                              width: 56, height: 56,
                                              color: Colors.blue.shade50,
                                              child: const Icon(Icons.menu_book, color: Colors.blue, size: 28),
                                            ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(book.bookName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Student ID: ${book.studentId.substring(0, 8)}...', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(book.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (book.status == 'Pending')
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.green),
                                            onPressed: () => _updateStatus(book, 'Approved'),
                                            tooltip: 'Approve',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: Colors.red),
                                            onPressed: () => _updateStatus(book, 'Rejected'),
                                            tooltip: 'Reject',
                                          ),
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
    );
  }
}
