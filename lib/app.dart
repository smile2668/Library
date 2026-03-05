import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/login_selection_screen.dart';
import 'screens/auth/student_login_screen.dart';
import 'screens/student/student_dashboard_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginSelectionScreen(),
      ),
      GoRoute(
        path: '/student-login',
        builder: (_, __) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (_, __) => const StudentDashboardScreen(),
      ),
    ],
    redirect: (_, state) {
      final user = authState.valueOrNull;
      final onLogin = state.matchedLocation == '/login' || state.matchedLocation == '/student-login';
      if (user == null && !onLogin) return '/login';
      return null;
    },
  );
});

class LibraryManagerApp extends ConsumerWidget {
  const LibraryManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'Self Study Library Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      routerConfig: router,
    );
  }
}
