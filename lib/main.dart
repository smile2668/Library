import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase_config.dart';
import 'providers/app_providers.dart';
import 'providers/auth_provider.dart';
import 'providers/library_provider.dart';
import 'providers/student_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await AppProviders.notificationService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: const LibraryManagerApp(),
    ),
  );
}
