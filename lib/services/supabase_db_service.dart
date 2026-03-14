import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/book_request_model.dart';
import '../models/expense_model.dart';
import '../models/fee_model.dart';
import '../models/library_model.dart';
import '../models/message_model.dart';
import '../models/note_model.dart';
import '../models/seat_model.dart';
import '../models/staff_model.dart';
import '../models/student_model.dart';
import '../models/study_session_model.dart';
import '../utils/constants.dart';

class SupabaseDbService {
  final SupabaseClient _client;

  const SupabaseDbService(this._client);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _id(Map<String, dynamic> map) => map['id'] as String;

  // ─── Library ──────────────────────────────────────────────────────────────

  Future<LibraryModel?> getLibraryByAdminId(String adminId) async {
    final data = await _client
        .from(AppConstants.tLibraries)
        .select()
        .eq('admin_id', adminId)
        .maybeSingle();
    return data == null ? null : LibraryModel.fromMap(_id(data), data);
  }

  Future<LibraryModel?> getLibraryByStaffId(String staffId) async {
    final staffData = await _client
        .from(AppConstants.tStaff)
        .select('library_id')
        .eq('id', staffId)
        .maybeSingle();
    if (staffData == null) return null;
    final libraryId = staffData['library_id'] as String?;
    if (libraryId == null) return null;
    final data = await _client
        .from(AppConstants.tLibraries)
        .select()
        .eq('id', libraryId)
        .maybeSingle();
    return data == null ? null : LibraryModel.fromMap(_id(data), data);
  }

  Future<void> createLibrary(LibraryModel library) async {
    await _client
        .from(AppConstants.tLibraries)
        .insert({'id': library.id, ...library.toMap()});
  }

  Future<void> updateLibrary(LibraryModel library) async {
    await _client
        .from(AppConstants.tLibraries)
        .update(library.toMap())
        .eq('id', library.id);
  }

  // ─── Students ─────────────────────────────────────────────────────────────

  Future<List<StudentModel>> getStudents(String libraryId) async {
    final data = await _client
        .from(AppConstants.tStudents)
        .select()
        .eq('library_id', libraryId)
        .order('name');
    return data.map<StudentModel>((m) => StudentModel.fromMap(_id(m), m)).toList();
  }

  Future<StudentModel?> getStudentById(String id) async {
    final data = await _client
        .from(AppConstants.tStudents)
        .select()
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : StudentModel.fromMap(_id(data), data);
  }

  Future<void> addStudent(StudentModel student) async {
    await _client
        .from(AppConstants.tStudents)
        .insert({'id': student.id, ...student.toMap()});
  }

  Future<void> updateStudent(StudentModel student) async {
    await _client
        .from(AppConstants.tStudents)
        .update(student.toMap())
        .eq('id', student.id);
  }

  Future<void> deleteStudent(String id) async {
    await _client.from(AppConstants.tStudents).delete().eq('id', id);
  }

  // ─── Staff ────────────────────────────────────────────────────────────────

  Future<List<StaffModel>> getStaff(String libraryId) async {
    final data = await _client
        .from(AppConstants.tStaff)
        .select()
        .eq('library_id', libraryId)
        .order('name');
    return data.map<StaffModel>((m) => StaffModel.fromMap(_id(m), m)).toList();
  }

  Future<StaffModel?> getStaffById(String id) async {
    final data = await _client
        .from(AppConstants.tStaff)
        .select()
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : StaffModel.fromMap(_id(data), data);
  }

  Future<void> addStaff(StaffModel staff) async {
    await _client
        .from(AppConstants.tStaff)
        .insert({'id': staff.id, ...staff.toMap()});
  }

  Future<void> updateStaff(StaffModel staff) async {
    await _client
        .from(AppConstants.tStaff)
        .update(staff.toMap())
        .eq('id', staff.id);
  }

  Future<void> deleteStaff(String id) async {
    await _client.from(AppConstants.tStaff).delete().eq('id', id);
  }

  // ─── Seats ────────────────────────────────────────────────────────────────

  Future<List<SeatModel>> getSeats(String libraryId) async {
    final data = await _client
        .from(AppConstants.tSeats)
        .select()
        .eq('library_id', libraryId)
        .order('number');
    return data.map<SeatModel>((m) => SeatModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addSeat(SeatModel seat) async {
    await _client
        .from(AppConstants.tSeats)
        .insert({'id': seat.id, ...seat.toMap()});
  }

  Future<void> updateSeat(SeatModel seat) async {
    await _client
        .from(AppConstants.tSeats)
        .update(seat.toMap())
        .eq('id', seat.id);
  }

  Future<void> deleteSeat(String id) async {
    await _client.from(AppConstants.tSeats).delete().eq('id', id);
  }

  // ─── Attendance ───────────────────────────────────────────────────────────

  Future<List<AttendanceModel>> getAttendance(String libraryId, {DateTime? date}) async {
    var query = _client
        .from(AppConstants.tAttendance)
        .select()
        .eq('library_id', libraryId);
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query
          .gte('timestamp', start.toIso8601String())
          .lt('timestamp', end.toIso8601String());
    }
    final data = await query.order('timestamp', ascending: false);
    return data.map<AttendanceModel>((m) => AttendanceModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addAttendance(AttendanceModel attendance) async {
    await _client
        .from(AppConstants.tAttendance)
        .insert({'id': attendance.id, ...attendance.toMap()});
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    await _client
        .from(AppConstants.tAttendance)
        .update(attendance.toMap())
        .eq('id', attendance.id);
  }

  Future<void> deleteAttendance(String id) async {
    await _client.from(AppConstants.tAttendance).delete().eq('id', id);
  }

  // ─── Fees ─────────────────────────────────────────────────────────────────

  Future<List<FeeModel>> getFees(String libraryId) async {
    final data = await _client
        .from(AppConstants.tFees)
        .select()
        .eq('library_id', libraryId)
        .order('due_date', ascending: false);
    return data.map<FeeModel>((m) => FeeModel.fromMap(_id(m), m)).toList();
  }

  Future<List<FeeModel>> getFeesByStudent(String studentId) async {
    final data = await _client
        .from(AppConstants.tFees)
        .select()
        .eq('student_id', studentId)
        .order('due_date', ascending: false);
    return data.map<FeeModel>((m) => FeeModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addFee(FeeModel fee) async {
    await _client
        .from(AppConstants.tFees)
        .insert({'id': fee.id, ...fee.toMap()});
  }

  Future<void> updateFee(FeeModel fee) async {
    await _client
        .from(AppConstants.tFees)
        .update(fee.toMap())
        .eq('id', fee.id);
  }

  Future<void> deleteFee(String id) async {
    await _client.from(AppConstants.tFees).delete().eq('id', id);
  }

  // ─── Books ────────────────────────────────────────────────────────────────

  Future<List<BookRequestModel>> getBooks(String libraryId) async {
    final data = await _client
        .from(AppConstants.tBooks)
        .select()
        .eq('library_id', libraryId)
        .order('book_name');
    return data.map<BookRequestModel>((m) => BookRequestModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addBook(BookRequestModel book) async {
    await _client
        .from(AppConstants.tBooks)
        .insert({'id': book.id, ...book.toMap()});
  }

  Future<void> updateBook(BookRequestModel book) async {
    await _client
        .from(AppConstants.tBooks)
        .update(book.toMap())
        .eq('id', book.id);
  }

  Future<void> deleteBook(String id) async {
    await _client.from(AppConstants.tBooks).delete().eq('id', id);
  }

  // ─── Expenses ─────────────────────────────────────────────────────────────

  Future<List<ExpenseModel>> getExpenses(String libraryId) async {
    final data = await _client
        .from(AppConstants.tExpenses)
        .select()
        .eq('library_id', libraryId)
        .order('date', ascending: false);
    return data.map<ExpenseModel>((m) => ExpenseModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _client
        .from(AppConstants.tExpenses)
        .insert({'id': expense.id, ...expense.toMap()});
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _client
        .from(AppConstants.tExpenses)
        .update(expense.toMap())
        .eq('id', expense.id);
  }

  Future<void> deleteExpense(String id) async {
    await _client.from(AppConstants.tExpenses).delete().eq('id', id);
  }

  // ─── Announcements ────────────────────────────────────────────────────────

  Future<List<AnnouncementModel>> getAnnouncements(String libraryId) async {
    final data = await _client
        .from(AppConstants.tAnnouncements)
        .select()
        .eq('library_id', libraryId)
        .order('created_at', ascending: false);
    return data.map<AnnouncementModel>((m) => AnnouncementModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    await _client
        .from(AppConstants.tAnnouncements)
        .insert({'id': announcement.id, ...announcement.toMap()});
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    await _client
        .from(AppConstants.tAnnouncements)
        .update(announcement.toMap())
        .eq('id', announcement.id);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client.from(AppConstants.tAnnouncements).delete().eq('id', id);
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getMessages(String libraryId, {String? userId}) async {
    var query = _client
        .from(AppConstants.tMessages)
        .select()
        .eq('library_id', libraryId);
    if (userId != null) {
      query = query.or('receiver_id.eq.$userId,receiver_id.is.null');
    }
    final data = await query.order('created_at', ascending: false);
    return data.map<MessageModel>((m) => MessageModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addMessage(MessageModel message) async {
    await _client
        .from(AppConstants.tMessages)
        .insert({'id': message.id, ...message.toMap()});
  }

  Future<void> markMessageRead(String id) async {
    await _client
        .from(AppConstants.tMessages)
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> deleteMessage(String id) async {
    await _client.from(AppConstants.tMessages).delete().eq('id', id);
  }

  // ─── Notes ────────────────────────────────────────────────────────────────

  Future<List<NoteModel>> getNotes(String libraryId) async {
    final data = await _client
        .from(AppConstants.tNotes)
        .select()
        .eq('library_id', libraryId)
        .order('created_at', ascending: false);
    return data.map<NoteModel>((m) => NoteModel.fromMap(_id(m), m)).toList();
  }

  Future<void> addNote(NoteModel note) async {
    await _client
        .from(AppConstants.tNotes)
        .insert({'id': note.id, ...note.toMap()});
  }

  Future<void> updateNote(NoteModel note) async {
    await _client
        .from(AppConstants.tNotes)
        .update(note.toMap())
        .eq('id', note.id);
  }

  Future<void> deleteNote(String id) async {
    await _client.from(AppConstants.tNotes).delete().eq('id', id);
  }

  // ─── Study Sessions ───────────────────────────────────────────────────────

  Future<List<StudySessionModel>> getStudySessions(String libraryId) async {
    final data = await _client
        .from(AppConstants.tStudySessions)
        .select()
        .eq('library_id', libraryId)
        .order('start_time', ascending: false);
    return data.map<StudySessionModel>((m) => StudySessionModel.fromMap(_id(m), m)).toList();
  }

  Future<StudySessionModel?> getActiveSession(String studentId) async {
    final data = await _client
        .from(AppConstants.tStudySessions)
        .select()
        .eq('student_id', studentId)
        .isFilter('end_time', null)
        .maybeSingle();
    return data == null ? null : StudySessionModel.fromMap(_id(data), data);
  }

  Future<void> addStudySession(StudySessionModel session) async {
    await _client
        .from(AppConstants.tStudySessions)
        .insert({'id': session.id, ...session.toMap()});
  }

  Future<void> updateStudySession(StudySessionModel session) async {
    await _client
        .from(AppConstants.tStudySessions)
        .update(session.toMap())
        .eq('id', session.id);
  }

  Future<void> deleteStudySession(String id) async {
    await _client.from(AppConstants.tStudySessions).delete().eq('id', id);
  }

  // ─── Role Resolution ──────────────────────────────────────────────────────

  /// Determines the role of a user by checking admins, staff, and students tables.
  /// Returns 'admin', 'staff', 'student', or null if not found.
  Future<String?> getUserRole(String userId) async {
    // Check admins table
    final adminData = await _client
        .from(AppConstants.tAdmins)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (adminData != null) return AppConstants.roleAdmin;

    // Check staff table
    final staffData = await _client
        .from(AppConstants.tStaff)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (staffData != null) return AppConstants.roleStaff;

    // Check students table
    final studentData = await _client
        .from(AppConstants.tStudents)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (studentData != null) return AppConstants.roleStudent;

    return null;
  }
}
