enum BookingStatus {
  PENDING, CONFIRMED, CANCELLED, COMPLETED
}

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String roomId;
  final String hotelName;
  final String roomName;
  final String hotelImage;
  final String checkInDate;
  final String checkOutDate;
  final int nights;
  final int guestsCount;
  final double pricePerNight;
  final double subtotal;
  final double taxFee;
  final double serviceFee;
  final double discountAmount;
  final double totalAmount;
  final String? appliedCoupon;
  final BookingStatus status;
  final String qrCode;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String paymentMethod;
  final int timestamp;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.hotelName,
    required this.roomName,
    required this.hotelImage,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.guestsCount,
    required this.pricePerNight,
    required this.subtotal,
    required this.taxFee,
    required this.serviceFee,
    required this.discountAmount,
    required this.totalAmount,
    this.appliedCoupon,
    this.status = BookingStatus.CONFIRMED,
    required this.qrCode,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.paymentMethod,
    required this.timestamp,
  });

  Booking copyWith({
    String? id,
    String? userId,
    String? hotelId,
    String? roomId,
    String? hotelName,
    String? roomName,
    String? hotelImage,
    String? checkInDate,
    String? checkOutDate,
    int? nights,
    int? guestsCount,
    double? pricePerNight,
    double? subtotal,
    double? taxFee,
    double? serviceFee,
    double? discountAmount,
    double? totalAmount,
    String? appliedCoupon,
    BookingStatus? status,
    String? qrCode,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? paymentMethod,
    int? timestamp,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      roomId: roomId ?? this.roomId,
      hotelName: hotelName ?? this.hotelName,
      roomName: roomName ?? this.roomName,
      hotelImage: hotelImage ?? this.hotelImage,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      nights: nights ?? this.nights,
      guestsCount: guestsCount ?? this.guestsCount,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      subtotal: subtotal ?? this.subtotal,
      taxFee: taxFee ?? this.taxFee,
      serviceFee: serviceFee ?? this.serviceFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      hotelId: json['hotelId'] ?? '',
      roomId: json['roomId'] ?? '',
      hotelName: json['hotelName'] ?? '',
      roomName: json['roomName'] ?? '',
      hotelImage: json['hotelImage'] ?? '',
      checkInDate: json['checkInDate'] ?? '',
      checkOutDate: json['checkOutDate'] ?? '',
      nights: json['nights'] ?? 1,
      guestsCount: json['guestsCount'] ?? 2,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxFee: (json['taxFee'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      appliedCoupon: json['appliedCoupon'],
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'CONFIRMED'),
        orElse: () => BookingStatus.CONFIRMED,
      ),
      qrCode: json['qrCode'] ?? '',
      guestName: json['guestName'] ?? '',
      guestEmail: json['guestEmail'] ?? '',
      guestPhone: json['guestPhone'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'Momo',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hotelId': hotelId,
      'roomId': roomId,
      'hotelName': hotelName,
      'roomName': roomName,
      'hotelImage': hotelImage,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'nights': nights,
      'guestsCount': guestsCount,
      'pricePerNight': pricePerNight,
      'subtotal': subtotal,
      'taxFee': taxFee,
      'serviceFee': serviceFee,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'appliedCoupon': appliedCoupon,
      'status': status.name,
      'qrCode': qrCode,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp,
    };
  }
}
