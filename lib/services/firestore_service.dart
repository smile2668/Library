import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';
import '../models/book_request_model.dart';
import '../models/fee_model.dart';
import '../models/library_model.dart';
import '../models/seat_model.dart';
import '../models/student_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  CollectionReference<Map<String, dynamic>> get libraries => _db.collection('libraries');
  CollectionReference<Map<String, dynamic>> get students => _db.collection('students');
  CollectionReference<Map<String, dynamic>> get seats => _db.collection('seats');
  CollectionReference<Map<String, dynamic>> get attendance => _db.collection('attendance');
  CollectionReference<Map<String, dynamic>> get fees => _db.collection('fees');
  CollectionReference<Map<String, dynamic>> get books => _db.collection('books');
  CollectionReference<Map<String, dynamic>> get admins => _db.collection('admins');

  Future<void> saveLibrary(LibraryModel library) => libraries.doc(library.id).set(library.toMap());

  Stream<List<LibraryModel>> searchLibraries(String query) {
    return libraries.snapshots().map((snapshot) {
      final all = snapshot.docs.map((doc) => LibraryModel.fromMap(doc.id, doc.data())).toList();
      if (query.isEmpty) return all;
      return all.where((l) => l.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Stream<List<StudentModel>> studentsByLibrary(String libraryId) => students
      .where('libraryId', isEqualTo: libraryId)
      .snapshots()
      .map((s) => s.docs.map((d) => StudentModel.fromMap(d.id, d.data())).toList());

  Future<void> addStudent(StudentModel student) => students.doc(student.id).set(student.toMap());

  Stream<List<SeatModel>> seatsByLibrary(String libraryId) =>
      seats.where('libraryId', isEqualTo: libraryId).snapshots().map(
            (s) => s.docs.map((d) => SeatModel.fromMap(d.id, d.data())).toList(),
          );

  Stream<List<FeeModel>> feesByLibrary(String libraryId) =>
      fees.where('libraryId', isEqualTo: libraryId).snapshots().map(
            (s) => s.docs.map((d) => FeeModel.fromMap(d.id, d.data())).toList(),
          );

  Future<void> saveFee(FeeModel fee) => fees.doc(fee.id).set(fee.toMap());

  Stream<List<AttendanceModel>> attendanceByLibrary(String libraryId) =>
      attendance.where('libraryId', isEqualTo: libraryId).snapshots().map(
            (s) => s.docs.map((d) => AttendanceModel.fromMap(d.id, d.data())).toList(),
          );

  Future<void> markAttendance(AttendanceModel entry) => attendance.doc(entry.id).set(entry.toMap());

  Stream<List<BookRequestModel>> booksByLibrary(String libraryId) =>
      books.where('libraryId', isEqualTo: libraryId).snapshots().map(
            (s) => s.docs.map((d) => BookRequestModel.fromMap(d.id, d.data())).toList(),
          );

  Future<void> saveBookRequest(BookRequestModel req) => books.doc(req.id).set(req.toMap());

  Future<void> updateBookRequestStatus(String id, String status) => books.doc(id).update({'status': status});
}
