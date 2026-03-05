import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Self Study Library Manager', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                child: const Text('Admin Login'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/student-login'),
                child: const Text('Student Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
