// lib/models/user.dart

class User {
  final String id;
  final String email;
  final String name;
  final String avatarUrl;
  final int loyaltyPoints;
  final String phoneNumber;
  final List<String> coupons;
  final String language;
  final bool isDarkMode;
  final bool isVerified;
  final String createdAt;
  final String role;

  User({
    this.id = 'user_123',
    this.email = 'vuonghoangtuananh6@gmail.com',
    this.name = 'Vương Hoàng Tuấn Anh',
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
    this.loyaltyPoints = 450,
    this.phoneNumber = '0987654321',
    this.coupons = const ['STAYEASE50', 'AGODASALE', 'WELCOME100'],
    this.language = 'VI',
    this.isDarkMode = false,
    this.isVerified = false,
    this.createdAt = '2026-05-23',
    this.role = 'USER',
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    int? loyaltyPoints,
    String? phoneNumber,
    List<String>? coupons,
    String? language,
    bool? isDarkMode,
    bool? isVerified,
    String? createdAt,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      coupons: coupons ?? this.coupons,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      coupons: List<String>.from(json['coupons'] ?? []),
      language: json['language'] ?? 'VI',
      isDarkMode: json['isDarkMode'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] ?? '',
      role: json['role'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'loyaltyPoints': loyaltyPoints,
      'phoneNumber': phoneNumber,
      'coupons': coupons,
      'language': language,
      'isDarkMode': isDarkMode,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'role': role,
    };
  }
}
