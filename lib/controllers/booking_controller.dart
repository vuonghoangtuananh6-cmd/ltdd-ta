import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';

class BookingController extends ChangeNotifier {
  static final BookingController _instance = BookingController._internal();
  factory BookingController() => _instance;
  BookingController._internal() {
    BookingRepository.init();
  }

  Hotel? selectedHotel;
  Room? selectedRoom;

  List<Booking> get bookings => BookingRepository.bookings.value;
  ValueNotifier<List<Booking>> get bookingsNotifier => BookingRepository.bookings;

  void selectRoom(Hotel hotel, Room room) {
    selectedHotel = hotel;
    selectedRoom = room;
    notifyListeners();
  }

  void createBooking(Booking booking) {
    BookingRepository.createBooking(booking);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    BookingRepository.updateBookingStatus(bookingId, BookingStatus.CANCELLED);
    notifyListeners();
  }

  double applyCoupon(String code, double amount) {
    final upper = code.trim().toUpperCase();
    if (upper == "STAYEASE200K" && amount >= 1000000) {
      return 200000.0;
    } else if (upper == "WELCOME500K" && amount >= 3000000) {
      return 500000.0;
    } else if (upper == "SUPERDEAL800K" && amount >= 5000000) {
      return 800000.0;
    } else if (upper == "STAYEASE50") {
      return 1150000.0; // approx $50 equivalent or generic $50 discount
    } else if (upper == "AGODASALE") {
      return amount * 0.15; // 15% discount
    }
    return 0.0;
  }
}
