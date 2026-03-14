import 'package:flutter/foundation.dart';

import '../models/student_model.dart';
import 'app_providers.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StudentModel> get students => List.unmodifiable(_students);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all students for [libraryId] and refreshes local list.
  Future<void> fetchStudents(String libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _students = await AppProviders.dbService.getStudents(libraryId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a student to the database and updates local list.
  Future<void> addStudent(StudentModel student) async {
    try {
      await AppProviders.dbService.addStudent(student);
      _students = [..._students, student];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Updates a student in the database and refreshes local list entry.
  Future<void> updateStudent(StudentModel student) async {
    try {
      await AppProviders.dbService.updateStudent(student);
      final idx = _students.indexWhere((s) => s.id == student.id);
      if (idx != -1) {
        _students = List.of(_students)..[idx] = student;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Deletes a student by [id] from the database and local list.
  Future<void> deleteStudent(String id) async {
    try {
      await AppProviders.dbService.deleteStudent(id);
      _students = _students.where((s) => s.id != id).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
