// lib/models/review.dart

import 'package:uuid/uuid.dart';

class Review {
  final String id;
  final String hotelId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.hotelId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Review copyWith({
    String? id,
    String? hotelId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    String? date,
  }) {
    return Review(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? const Uuid().v4(),
      hotelId: json['hotelId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}
