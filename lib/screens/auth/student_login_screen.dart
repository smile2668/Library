import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/library_model.dart';
import '../../providers/app_providers.dart';

class StudentLoginScreen extends ConsumerStatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  ConsumerState<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends ConsumerState<StudentLoginScreen> {
  final _searchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  LibraryModel? _selected;

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search library by name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<LibraryModel>>(
                stream: fs.searchLibraries(_searchController.text),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final lib = items[i];
                      return RadioListTile<LibraryModel>(
                        value: lib,
                        groupValue: _selected,
                        title: Text(lib.name),
                        onChanged: (v) => setState(() => _selected = v),
                      );
                    },
                  );
                },
              ),
            ),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Registered Mobile Number')),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _selected == null ? null : () => context.go('/student'),
              child: const Text('Login as Student'),
            ),
          ],
        ),
      ),
    );
  }
}
