class Coupon {
  final String code;
  final String description;
  final int discountPercent;
  final double maxDiscount;
  final double minSpend;

  Coupon({
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.maxDiscount,
    required this.minSpend,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountPercent: json['discountPercent'] ?? 0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble() ?? 0.0,
      minSpend: (json['minSpend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'discountPercent': discountPercent,
      'maxDiscount': maxDiscount,
      'minSpend': minSpend,
    };
  }
}
