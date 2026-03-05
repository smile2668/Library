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
        'libraryId': libraryId,
        'number': number,
        'occupied': occupied,
        'studentId': studentId,
      };

  factory SeatModel.fromMap(String id, Map<String, dynamic> map) => SeatModel(
        id: id,
        libraryId: map['libraryId'] as String? ?? '',
        number: map['number'] as int? ?? 0,
        occupied: map['occupied'] as bool? ?? false,
        studentId: map['studentId'] as String?,
      );
}
