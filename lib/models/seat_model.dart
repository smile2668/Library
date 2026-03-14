class SeatModel {
  final String id;
  final String libraryId;
  final int number;
  final bool occupied;
  final String? studentId;

  const SeatModel({
    required this.id,
    required this.libraryId,
    required this.number,
    required this.occupied,
    this.studentId,
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'number': number,
        'occupied': occupied,
        'student_id': studentId,
      };

  factory SeatModel.fromMap(String id, Map<String, dynamic> map) => SeatModel(
        id: id,
        libraryId: map['library_id'] as String? ?? map['libraryId'] as String? ?? '',
        number: map['number'] as int? ?? 0,
        occupied: map['occupied'] as bool? ?? false,
        studentId: map['student_id'] as String? ?? map['studentId'] as String?,
      );

  SeatModel copyWith({
    String? id,
    String? libraryId,
    int? number,
    bool? occupied,
    String? studentId,
  }) =>
      SeatModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        number: number ?? this.number,
        occupied: occupied ?? this.occupied,
        studentId: studentId ?? this.studentId,
      );
}
