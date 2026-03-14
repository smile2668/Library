class AppConstants {
  static const supabaseUrl = 'https://kknjnxncjbttzxwznuue.supabase.co';

  // The anon key is the public client key intended to be embedded in client apps.
  // Access is governed by Supabase Row-Level Security (RLS) policies.
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrbmpueG5jamJ0dHp4d3pudXVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyMDA0NDksImV4cCI6MjA4ODc3NjQ0OX0.YXVrM-gJhU4RpOKXt1dY9R-v-Z_wO5kE22aDjWYaIlQ';

  // Table names
  static const tLibraries = 'libraries';
  static const tAdmins = 'admins';
  static const tStaff = 'staff';
  static const tStudents = 'students';
  static const tSeats = 'seats';
  static const tAttendance = 'attendance';
  static const tFees = 'fees';
  static const tBooks = 'books';
  static const tExpenses = 'expenses';
  static const tMessages = 'messages';
  static const tNotes = 'notes';
  static const tAnnouncements = 'announcements';
  static const tStudySessions = 'study_sessions';

  // Storage buckets
  static const bucketLibraryImages = 'library_images';
  static const bucketStudentPhotos = 'student_photos';
  static const bucketStaffPhotos = 'staff_photos';
  static const bucketAadharImages = 'aadhar_images';
  static const bucketBookImages = 'book_images';
  static const bucketNotesFiles = 'notes_files';

  // Roles
  static const roleAdmin = 'admin';
  static const roleStaff = 'staff';
  static const roleStudent = 'student';

  // Fee plans
  static const List<String> feePlans = ['1 Month', '3 Months', '6 Months', '1 Year'];

  // Study times
  static const List<String> studyTimes = [
    '3 Hours',
    '6 Hours',
    'Half Day',
    'Full Day',
    'Day',
    'Night',
  ];

  // Expense categories
  static const List<String> expenseCategories = [
    'Electricity',
    'Rent',
    'Internet',
    'Cleaning',
    'Other',
  ];

  // Priority levels
  static const List<String> priorityLevels = ['low', 'medium', 'high'];
}
