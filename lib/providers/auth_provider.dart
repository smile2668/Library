import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_providers.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  User? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initializes the provider by restoring the current session and listening
  /// for future auth state changes.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = AppProviders.authService.getCurrentUser();
    if (_currentUser != null) {
      _userRole = await AppProviders.dbService.getUserRole(_currentUser!.id);
    }

    _isLoading = false;
    notifyListeners();

    _authSubscription = AppProviders.authService.authStateChanges().listen(_onAuthStateChange);
  }

  Future<void> _onAuthStateChange(AuthState state) async {
    _currentUser = state.session?.user;
    if (_currentUser != null) {
      _userRole = await AppProviders.dbService.getUserRole(_currentUser!.id);
    } else {
      _userRole = null;
    }
    notifyListeners();
  }

  /// Sends an OTP to [phone]. Sets [errorMessage] on failure.
  Future<void> signInWithOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await AppProviders.authService.signInWithOtp(phone: phone);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies the OTP [token] for [phone]. Returns true on success.
  Future<bool> verifyOtp(String phone, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await AppProviders.authService.verifyOtp(phone: phone, token: token);
      if (user != null) {
        _currentUser = user;
        _userRole = await AppProviders.dbService.getUserRole(user.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Signs out the current user and clears local state.
  Future<void> signOut() async {
    await AppProviders.authService.signOut();
    _currentUser = null;
    _userRole = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
