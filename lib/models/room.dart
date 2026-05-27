// lib/models/room.dart

class Room {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final double price;
  final String bedType;
  final int maxGuests;
  final int sizeSqm;
  final List<String> imageUrls;
  final List<String> amenities;
  final int totalAvailable;

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.price,
    required this.bedType,
    required this.maxGuests,
    required this.sizeSqm,
    required this.imageUrls,
    required this.amenities,
    this.totalAvailable = 5,
  });

  Room copyWith({
    String? id,
    String? hotelId,
    String? name,
    String? description,
    double? price,
    String? bedType,
    int? maxGuests,
    int? sizeSqm,
    List<String>? imageUrls,
    List<String>? amenities,
    int? totalAvailable,
  }) {
    return Room(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      bedType: bedType ?? this.bedType,
      maxGuests: maxGuests ?? this.maxGuests,
      sizeSqm: sizeSqm ?? this.sizeSqm,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      totalAvailable: totalAvailable ?? this.totalAvailable,
    );
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      bedType: json['bedType'] ?? '',
      maxGuests: json['maxGuests'] ?? 2,
      sizeSqm: json['sizeSqm'] ?? 30,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      totalAvailable: json['totalAvailable'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'name': name,
      'description': description,
      'price': price,
      'bedType': bedType,
      'maxGuests': maxGuests,
      'sizeSqm': sizeSqm,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'totalAvailable': totalAvailable,
    };
  }
}
