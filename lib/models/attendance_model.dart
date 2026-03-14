class AttendanceModel {
  final String id;
  final String libraryId;
  final String studentId;
  final DateTime timestamp;
  final String status;

  const AttendanceModel({
    required this.id,
    required this.libraryId,
    required this.studentId,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'student_id': studentId,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> map) => AttendanceModel(
        id: id,
        libraryId: map['library_id'] as String? ?? map['libraryId'] as String? ?? '',
        studentId: map['student_id'] as String? ?? map['studentId'] as String? ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
        status: map['status'] as String? ?? 'Pending',
      );

  AttendanceModel copyWith({
    String? id,
    String? libraryId,
    String? studentId,
    DateTime? timestamp,
    String? status,
  }) =>
      AttendanceModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        studentId: studentId ?? this.studentId,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
      );
}
