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
  final String photoUrl;
  final String aadharNumber;
  final String aadharImageUrl;
  final DateTime? birthday;

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
    this.photoUrl = '',
    this.aadharNumber = '',
    this.aadharImageUrl = '',
    this.birthday,
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'name': name,
        'mobile': mobile,
        'joining_date': joiningDate.toIso8601String(),
        'seat_number': seatNumber,
        'seat_type': seatType,
        'study_time': studyTime,
        'role': role,
        'password_set': passwordSet,
        'photo_url': photoUrl,
        'aadhar_number': aadharNumber,
        'aadhar_image_url': aadharImageUrl,
        'birthday': birthday?.toIso8601String(),
      };

  factory StudentModel.fromMap(String id, Map<String, dynamic> map) => StudentModel(
        id: id,
        libraryId: map['library_id'] as String? ?? map['libraryId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        mobile: map['mobile'] as String? ?? '',
        joiningDate: DateTime.tryParse(
                map['joining_date'] as String? ?? map['joiningDate'] as String? ?? '') ??
            DateTime.now(),
        seatNumber: map['seat_number'] as int? ?? map['seatNumber'] as int? ?? 0,
        seatType: map['seat_type'] as String? ?? map['seatType'] as String? ?? 'Free Seat',
        studyTime: map['study_time'] as String? ?? map['studyTime'] as String? ?? 'Full Day',
        role: map['role'] as String? ?? 'student',
        passwordSet: map['password_set'] as bool? ?? map['passwordSet'] as bool? ?? false,
        photoUrl: map['photo_url'] as String? ?? '',
        aadharNumber: map['aadhar_number'] as String? ?? '',
        aadharImageUrl: map['aadhar_image_url'] as String? ?? '',
        birthday: map['birthday'] != null
            ? DateTime.tryParse(map['birthday'] as String)
            : null,
      );

  StudentModel copyWith({
    String? id,
    String? libraryId,
    String? name,
    String? mobile,
    DateTime? joiningDate,
    int? seatNumber,
    String? seatType,
    String? studyTime,
    String? role,
    bool? passwordSet,
    String? photoUrl,
    String? aadharNumber,
    String? aadharImageUrl,
    DateTime? birthday,
  }) =>
      StudentModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        joiningDate: joiningDate ?? this.joiningDate,
        seatNumber: seatNumber ?? this.seatNumber,
        seatType: seatType ?? this.seatType,
        studyTime: studyTime ?? this.studyTime,
        role: role ?? this.role,
        passwordSet: passwordSet ?? this.passwordSet,
        photoUrl: photoUrl ?? this.photoUrl,
        aadharNumber: aadharNumber ?? this.aadharNumber,
        aadharImageUrl: aadharImageUrl ?? this.aadharImageUrl,
        birthday: birthday ?? this.birthday,
      );
}
