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
        'libraryId': libraryId,
        'studentId': studentId,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> map) => AttendanceModel(
        id: id,
        libraryId: map['libraryId'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
        status: map['status'] as String? ?? 'Pending',
      );
}
