class NoteModel {
  final String id;
  final String libraryId;
  final String title;
  final String fileUrl;
  final String fileType;
  final String uploadedBy;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.libraryId,
    required this.title,
    required this.fileUrl,
    this.fileType = 'pdf',
    required this.uploadedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'title': title,
        'file_url': fileUrl,
        'file_type': fileType,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
      };

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) => NoteModel(
        id: id,
        libraryId: map['library_id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        fileUrl: map['file_url'] as String? ?? '',
        fileType: map['file_type'] as String? ?? 'pdf',
        uploadedBy: map['uploaded_by'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  NoteModel copyWith({
    String? id,
    String? libraryId,
    String? title,
    String? fileUrl,
    String? fileType,
    String? uploadedBy,
    DateTime? createdAt,
  }) =>
      NoteModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        title: title ?? this.title,
        fileUrl: fileUrl ?? this.fileUrl,
        fileType: fileType ?? this.fileType,
        uploadedBy: uploadedBy ?? this.uploadedBy,
        createdAt: createdAt ?? this.createdAt,
      );
}
