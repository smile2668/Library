class BookRequestModel {
  final String id;
  final String libraryId;
  final String studentId;
  final String bookName;
  final String imageUrl;
  final String status;

  const BookRequestModel({
    required this.id,
    required this.libraryId,
    required this.studentId,
    required this.bookName,
    this.imageUrl = '',
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'student_id': studentId,
        'book_name': bookName,
        'image_url': imageUrl,
        'status': status,
      };

  factory BookRequestModel.fromMap(String id, Map<String, dynamic> map) => BookRequestModel(
        id: id,
        libraryId: map['library_id'] as String? ?? map['libraryId'] as String? ?? '',
        studentId: map['student_id'] as String? ?? map['studentId'] as String? ?? '',
        bookName: map['book_name'] as String? ?? map['bookName'] as String? ?? '',
        imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? '',
        status: map['status'] as String? ?? 'Pending',
      );

  BookRequestModel copyWith({
    String? id,
    String? libraryId,
    String? studentId,
    String? bookName,
    String? imageUrl,
    String? status,
  }) =>
      BookRequestModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        studentId: studentId ?? this.studentId,
        bookName: bookName ?? this.bookName,
        imageUrl: imageUrl ?? this.imageUrl,
        status: status ?? this.status,
      );
}
