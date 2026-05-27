// lib/models/payment.dart

import 'package:uuid/uuid.dart';

class Payment {
  final String id;
  final String bookingId;
  final String paymentMethod;
  final double amount;
  final String status;
  final int timestamp;

  Payment({
    required this.id,
    required this.bookingId,
    required this.paymentMethod,
    required this.amount,
    this.status = "SUCCESS",
    required this.timestamp,
  });

  Payment copyWith({
    String? id,
    String? bookingId,
    String? paymentMethod,
    double? amount,
    String? status,
    int? timestamp,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? const Uuid().v4().substring(0, 10).toUpperCase(),
      bookingId: json['bookingId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'Momo',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'SUCCESS',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
