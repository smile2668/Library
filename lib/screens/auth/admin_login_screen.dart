import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone (+91...)')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await auth.sendOtp(
                  phone: _phoneController.text.trim(),
                  onCodeSent: (id, _) => setState(() => _verificationId = id),
                  onError: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'OTP failed'))),
                );
              },
              child: const Text('Send OTP'),
            ),
            if (_verificationId != null) ...[
              const SizedBox(height: 16),
              TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'Enter OTP')),
              ElevatedButton(
                onPressed: () async {
                  await auth.verifyOtp(verificationId: _verificationId!, otp: _otpController.text.trim());
                  if (context.mounted) context.go('/admin');
                },
                child: const Text('Verify & Login'),
              )
            ]
          ],
        ),
      ),
    );
  }
}
