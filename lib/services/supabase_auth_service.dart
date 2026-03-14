import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Sends an OTP to the given phone number.
  Future<void> signInWithOtp({required String phone}) async {
    await _auth.signInWithOtp(phone: phone);
  }

  /// Verifies the OTP and returns the authenticated [User], or null on failure.
  Future<User?> verifyOtp({required String phone, required String token}) async {
    final response = await _auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
    return response.user;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the currently authenticated user, or null.
  User? getCurrentUser() => _auth.currentUser;

  /// Stream of authentication state changes.
  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;
}
