import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/library_provider.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/login_selection_screen.dart';
import 'screens/setup/library_setup_screen.dart';
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

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _checkingLibrary = false;
  bool _libraryChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final role = auth.userRole;
    if (!_libraryChecked &&
        auth.currentUser != null &&
        (role == AppConstants.roleAdmin || role == AppConstants.roleStaff)) {
      _checkLibrary(auth.currentUser!.id);
    }
    if (auth.currentUser == null) {
      _libraryChecked = false;
    }
  }

  Future<void> _checkLibrary(String userId) async {
    if (_checkingLibrary) return;
    _checkingLibrary = true;
    await context.read<LibraryProvider>().fetchLibrary(userId);
    if (mounted) {
      setState(() {
        _libraryChecked = true;
        _checkingLibrary = false;
      });
    }
  }

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
        if (!_libraryChecked) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final library = context.watch<LibraryProvider>().currentLibrary;
        // First-time admin: no library set up yet
        if (library == null && auth.userRole == AppConstants.roleAdmin) {
          return const LibrarySetupScreen();
        }
        return const AdminDashboardScreen();
      case AppConstants.roleStudent:
        return const StudentDashboardScreen();
      default:
        return const LoginSelectionScreen();
    }
  }
}
