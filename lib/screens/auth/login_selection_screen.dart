import 'package:flutter/material.dart';

import 'admin_login_screen.dart';
import 'staff_login_screen.dart';
import 'student_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top decorative space
              const Spacer(flex: 2),

              // Logo and title section
              Hero(
                tag: 'app-logo',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: const CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.local_library, size: 48, color: Color(0xFF3949AB)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Self Study\nLibrary Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Learning Hub',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // Login buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Text(
                      'Login as',
                      style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1),
                    ),
                    const SizedBox(height: 16),
                    _LoginButton(
                      label: 'Admin Login',
                      icon: Icons.admin_panel_settings,
                      color: Colors.white,
                      textColor: const Color(0xFF3949AB),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                    ),
                    const SizedBox(height: 12),
                    _LoginButton(
                      label: 'Staff Login',
                      icon: Icons.work,
                      color: Colors.white.withValues(alpha: 0.15),
                      textColor: Colors.white,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffLoginScreen())),
                    ),
                    const SizedBox(height: 12),
                    _LoginButton(
                      label: 'Student Login',
                      icon: Icons.school,
                      color: Colors.white.withValues(alpha: 0.15),
                      textColor: Colors.white,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentLoginScreen())),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Version footer
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'v1.0.0 • Powered by Supabase',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _LoginButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 22),
        label: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
