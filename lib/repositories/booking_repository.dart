import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../service/database_helper.dart';
import 'user_repository.dart';

class BookingRepository {
  static final bookings = ValueNotifier<List<Booking>>([]);
  static bool _isInitialized = false;

  static void init() {
    if (!_isInitialized) {
      final savedText = DatabaseHelper.loadList<Booking>('saved_bookings', (json) => Booking.fromJson(json));
      if (savedText.isNotEmpty) {
        bookings.value = savedText;
      } else {
        bookings.value = _loadDefaultBookings();
        _saveBookings();
      }
      _isInitialized = true;
    }
  }

  static void _saveBookings() {
    DatabaseHelper.saveList<Booking>('saved_bookings', bookings.value, (item) => item.toJson());
  }

  static void createBooking(Booking booking) {
    bookings.value = [booking, ...bookings.value];
    _saveBookings();

    UserRepository.init();
    UserRepository.rewardLoyaltyPoints(50);
  }

  static void updateBookingStatus(String bookingId, BookingStatus status) {
    bookings.value = bookings.value.map((it) {
      if (it.id == bookingId) {
        return it.copyWith(status: status);
      }
      return it;
    }).toList();
    _saveBookings();
  }

  static List<Booking> _loadDefaultBookings() {
    return [
      Booking(
        id: "B5201A",
        userId: "user_123",
        hotelId: "hotel_1",
        roomId: "r1_1",
        hotelName: "Sofitel Legend Metropole Hanoi",
        roomName: "Classic Luxury King Room",
        hotelImage: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=300&q=80",
        checkInDate: "2026-06-15",
        checkOutDate: "2026-06-17",
        nights: 2,
        guestsCount: 2,
        pricePerNight: 4200000.0,
        subtotal: 8400000.0,
        taxFee: 84000.0,
        serviceFee: 42000.0,
        discountAmount: 200000.0,
        totalAmount: 8326000.0,
        appliedCoupon: "STAYEASE200K",
        status: BookingStatus.CONFIRMED,
        qrCode: "STAYEASE-B5201A",
        guestName: "Vương Hoàng Tuấn Anh",
        guestEmail: "vuonghoangtuananh6@gmail.com",
        guestPhone: "0987654321",
        paymentMethod: "Momo",
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
      Booking(
        id: "B8721C",
        userId: "user_123",
        hotelId: "hotel_3",
        roomId: "r3_1",
        hotelName: "Hotel de la Coupole - MGallery Sapa",
        roomName: "Classic Indochine Room",
        hotelImage: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=300&q=80",
        checkInDate: "2026-05-01",
        checkOutDate: "2026-05-04",
        nights: 3,
        guestsCount: 2,
        pricePerNight: 2400000.0,
        subtotal: 7200000.0,
        taxFee: 72000.0,
        serviceFee: 36000.0,
        discountAmount: 0.0,
        totalAmount: 7308000.0,
        appliedCoupon: null,
        status: BookingStatus.COMPLETED,
        qrCode: "STAYEASE-B8721C",
        guestName: "Vương Hoàng Tuấn Anh",
        guestEmail: "vuonghoangtuananh6@gmail.com",
        guestPhone: "0987654321",
        paymentMethod: "VNPay",
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
  }
}
