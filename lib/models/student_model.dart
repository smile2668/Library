class StudentModel {
  final String id;
  final String libraryId;
  final String name;
  final String mobile;
  final DateTime joiningDate;
  final int seatNumber;
  final String seatType;
  final String studyTime;
  final String role;
  final bool passwordSet;

  const StudentModel({
    required this.id,
    required this.libraryId,
    required this.name,
    required this.mobile,
    required this.joiningDate,
    required this.seatNumber,
    required this.seatType,
    required this.studyTime,
    this.role = 'student',
    this.passwordSet = false,
  });

  Map<String, dynamic> toMap() => {
        'libraryId': libraryId,
        'name': name,
        'mobile': mobile,
        'joiningDate': joiningDate.toIso8601String(),
        'seatNumber': seatNumber,
        'seatType': seatType,
        'studyTime': studyTime,
        'role': role,
        'passwordSet': passwordSet,
      };

  factory StudentModel.fromMap(String id, Map<String, dynamic> map) => StudentModel(
        id: id,
        libraryId: map['libraryId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        mobile: map['mobile'] as String? ?? '',
        joiningDate: DateTime.tryParse(map['joiningDate'] as String? ?? '') ?? DateTime.now(),
        seatNumber: map['seatNumber'] as int? ?? 0,
        seatType: map['seatType'] as String? ?? 'Free Seat',
        studyTime: map['studyTime'] as String? ?? 'Full Day',
        role: map['role'] as String? ?? 'student',
        passwordSet: map['passwordSet'] as bool? ?? false,
      );
}
