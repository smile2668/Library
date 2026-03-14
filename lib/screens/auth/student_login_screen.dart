import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    await context.read<AuthProvider>().signInWithOtp(phone);
    if (!mounted) return;
    final error = context.read<AuthProvider>().errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      setState(() => _otpSent = true);
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final token = _otpController.text.trim();
    if (phone.isEmpty || token.isEmpty) return;
    final success = await context.read<AuthProvider>().verifyOtp(phone, token);
    if (!mounted) return;
    if (success) {
      // Pop back to _AppRoot which will redirect to the correct dashboard.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final error = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error ?? 'OTP verification failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Registered mobile number (+91...)',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify & Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
