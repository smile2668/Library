class LibraryModel {
  final String id;
  final String name;
  final String logoUrl;
  final int totalSeats;
  final int freeSeats;
  final String adminId;
  final String address;
  final String mapsLink;
  final String websiteLink;
  final double seatPrice;
  final List<String> imageUrls;

  const LibraryModel({
    required this.id,
    required this.name,
    this.logoUrl = '',
    required this.totalSeats,
    required this.freeSeats,
    required this.adminId,
    this.address = '',
    this.mapsLink = '',
    this.websiteLink = '',
    this.seatPrice = 0.0,
    this.imageUrls = const [],
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'logo_url': logoUrl,
        'total_seats': totalSeats,
        'free_seats': freeSeats,
        'admin_id': adminId,
        'address': address,
        'maps_link': mapsLink,
        'website_link': websiteLink,
        'seat_price': seatPrice,
        'image_urls': imageUrls,
      };

  factory LibraryModel.fromMap(String id, Map<String, dynamic> map) => LibraryModel(
        id: id,
        name: map['name'] as String? ?? '',
        logoUrl: map['logo_url'] as String? ?? map['logoUrl'] as String? ?? '',
        totalSeats: map['total_seats'] as int? ?? map['totalSeats'] as int? ?? 0,
        freeSeats: map['free_seats'] as int? ?? map['freeSeats'] as int? ?? 0,
        adminId: map['admin_id'] as String? ?? map['adminId'] as String? ?? '',
        address: map['address'] as String? ?? '',
        mapsLink: map['maps_link'] as String? ?? '',
        websiteLink: map['website_link'] as String? ?? '',
        seatPrice: (map['seat_price'] as num?)?.toDouble() ?? 0.0,
        imageUrls: (map['image_urls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  LibraryModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    int? totalSeats,
    int? freeSeats,
    String? adminId,
    String? address,
    String? mapsLink,
    String? websiteLink,
    double? seatPrice,
    List<String>? imageUrls,
  }) =>
      LibraryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        totalSeats: totalSeats ?? this.totalSeats,
        freeSeats: freeSeats ?? this.freeSeats,
        adminId: adminId ?? this.adminId,
        address: address ?? this.address,
        mapsLink: mapsLink ?? this.mapsLink,
        websiteLink: websiteLink ?? this.websiteLink,
        seatPrice: seatPrice ?? this.seatPrice,
        imageUrls: imageUrls ?? this.imageUrls,
      );
}
