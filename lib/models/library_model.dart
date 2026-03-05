class LibraryModel {
  final String id;
  final String name;
  final String logoUrl;
  final int totalSeats;
  final int freeSeats;
  final String adminId;

  const LibraryModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.totalSeats,
    required this.freeSeats,
    required this.adminId,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'logoUrl': logoUrl,
        'totalSeats': totalSeats,
        'freeSeats': freeSeats,
        'adminId': adminId,
      };

  factory LibraryModel.fromMap(String id, Map<String, dynamic> map) => LibraryModel(
        id: id,
        name: map['name'] as String? ?? '',
        logoUrl: map['logoUrl'] as String? ?? '',
        totalSeats: map['totalSeats'] as int? ?? 0,
        freeSeats: map['freeSeats'] as int? ?? 0,
        adminId: map['adminId'] as String? ?? '',
      );
}
