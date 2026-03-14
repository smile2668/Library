class AnnouncementModel {
  final String id;
  final String libraryId;
  final String title;
  final String message;
  final String imageUrl;
  final String priority;
  final DateTime createdAt;
  final String createdBy;

  const AnnouncementModel({
    required this.id,
    required this.libraryId,
    required this.title,
    required this.message,
    this.imageUrl = '',
    this.priority = 'low',
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'title': title,
        'message': message,
        'image_url': imageUrl,
        'priority': priority,
        'created_at': createdAt.toIso8601String(),
        'created_by': createdBy,
      };

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> map) => AnnouncementModel(
        id: id,
        libraryId: map['library_id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        message: map['message'] as String? ?? '',
        imageUrl: map['image_url'] as String? ?? '',
        priority: map['priority'] as String? ?? 'low',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
        createdBy: map['created_by'] as String? ?? '',
      );

  AnnouncementModel copyWith({
    String? id,
    String? libraryId,
    String? title,
    String? message,
    String? imageUrl,
    String? priority,
    DateTime? createdAt,
    String? createdBy,
  }) =>
      AnnouncementModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        title: title ?? this.title,
        message: message ?? this.message,
        imageUrl: imageUrl ?? this.imageUrl,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
      );
}
