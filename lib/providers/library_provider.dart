import 'package:flutter/foundation.dart';

import '../models/library_model.dart';
import 'app_providers.dart';

class LibraryProvider extends ChangeNotifier {
  LibraryModel? _currentLibrary;
  bool _isLoading = false;
  String? _errorMessage;

  LibraryModel? get currentLibrary => _currentLibrary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches the library for the given user (admin or staff).
  Future<void> fetchLibrary(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentLibrary = await AppProviders.dbService.getLibraryByAdminId(userId);
      _currentLibrary ??= await AppProviders.dbService.getLibraryByStaffId(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new library record and updates local state.
  Future<void> saveLibrary(LibraryModel library) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await AppProviders.dbService.createLibrary(library);
      _currentLibrary = library;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing library record and updates local state.
  Future<void> updateLibrary(LibraryModel library) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await AppProviders.dbService.updateLibrary(library);
      _currentLibrary = library;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
