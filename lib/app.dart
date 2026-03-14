import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/login_selection_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

class LibraryManagerApp extends StatelessWidget {
  const LibraryManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Self Study Library Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.currentUser == null) {
      return const LoginSelectionScreen();
    }

    switch (auth.userRole) {
      case AppConstants.roleAdmin:
      case AppConstants.roleStaff:
        return const AdminDashboardScreen();
      case AppConstants.roleStudent:
        return const StudentDashboardScreen();
      default:
        return const LoginSelectionScreen();
    }
  }
}
