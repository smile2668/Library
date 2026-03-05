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
    required this.imageUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'libraryId': libraryId,
        'studentId': studentId,
        'bookName': bookName,
        'imageUrl': imageUrl,
        'status': status,
      };

  factory BookRequestModel.fromMap(String id, Map<String, dynamic> map) => BookRequestModel(
        id: id,
        libraryId: map['libraryId'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        bookName: map['bookName'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        status: map['status'] as String? ?? 'Pending',
      );
}
