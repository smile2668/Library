class StudySessionModel {
  final String id;
  final String studentId;
  final String libraryId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;

  const StudySessionModel({
    required this.id,
    required this.studentId,
    required this.libraryId,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
  });

  bool get isActive => endTime == null;

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'library_id': libraryId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'duration_minutes': durationMinutes,
      };

  factory StudySessionModel.fromMap(String id, Map<String, dynamic> map) => StudySessionModel(
        id: id,
        studentId: map['student_id'] as String? ?? '',
        libraryId: map['library_id'] as String? ?? '',
        startTime: DateTime.tryParse(map['start_time'] as String? ?? '') ?? DateTime.now(),
        endTime: map['end_time'] != null
            ? DateTime.tryParse(map['end_time'] as String)
            : null,
        durationMinutes: map['duration_minutes'] as int?,
      );

  StudySessionModel copyWith({
    String? id,
    String? studentId,
    String? libraryId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
  }) =>
      StudySessionModel(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        libraryId: libraryId ?? this.libraryId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );
}
