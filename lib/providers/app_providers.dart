import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/notification_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_db_service.dart';
import '../services/supabase_storage_service.dart';

/// Central registry for all service singletons.
/// Services are lazily initialized on first access, ensuring Supabase
/// is already initialized before any service is used.
class AppProviders {
  AppProviders._();

  static SupabaseClient get client => Supabase.instance.client;

  static late final SupabaseAuthService authService = SupabaseAuthService();
  static late final SupabaseDbService dbService = SupabaseDbService(client);
  static late final SupabaseStorageService storageService = SupabaseStorageService();
  static late final NotificationService notificationService = NotificationService();
}
