class Hotel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final int stars;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final List<String> amenities;
  final double priceMin;
  final double latitude;
  final double longitude;
  final bool isFeatured;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.stars,
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.amenities,
    required this.priceMin,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isFeatured = false,
  });

  Hotel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    int? stars,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    List<String>? amenities,
    double? priceMin,
    double? latitude,
    double? longitude,
    bool? isFeatured,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      stars: stars ?? this.stars,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      priceMin: priceMin ?? this.priceMin,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      stars: json['stars'] ?? 3,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      priceMin: (json['priceMin'] as num?)?.toDouble() ?? 100.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'stars': stars,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'priceMin': priceMin,
      'latitude': latitude,
      'longitude': longitude,
      'isFeatured': isFeatured,
    };
  }
}
