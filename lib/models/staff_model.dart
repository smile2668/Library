class StaffModel {
  final String id;
  final String libraryId;
  final String name;
  final String phone;
  final String photoUrl;
  final String role;
  final bool passwordSet;
  final DateTime createdAt;

  const StaffModel({
    required this.id,
    required this.libraryId,
    required this.name,
    required this.phone,
    this.photoUrl = '',
    this.role = 'staff',
    this.passwordSet = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'name': name,
        'phone': phone,
        'photo_url': photoUrl,
        'role': role,
        'password_set': passwordSet,
        'created_at': createdAt.toIso8601String(),
      };

  factory StaffModel.fromMap(String id, Map<String, dynamic> map) => StaffModel(
        id: id,
        libraryId: map['library_id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        photoUrl: map['photo_url'] as String? ?? '',
        role: map['role'] as String? ?? 'staff',
        passwordSet: map['password_set'] as bool? ?? false,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  StaffModel copyWith({
    String? id,
    String? libraryId,
    String? name,
    String? phone,
    String? photoUrl,
    String? role,
    bool? passwordSet,
    DateTime? createdAt,
  }) =>
      StaffModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        photoUrl: photoUrl ?? this.photoUrl,
        role: role ?? this.role,
        passwordSet: passwordSet ?? this.passwordSet,
        createdAt: createdAt ?? this.createdAt,
      );
}
