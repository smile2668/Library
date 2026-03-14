import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
