import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../repositories/hotel_repository.dart';
import '../repositories/booking_repository.dart';

class AdminController extends ChangeNotifier {
  static final AdminController _instance = AdminController._internal();
  factory AdminController() => _instance;
  AdminController._internal() {
    HotelRepository.init();
    BookingRepository.init();
  }

  // Get stats Map
  Map<String, dynamic> get adminStats {
    final listHotels = HotelRepository.hotels.value;
    final listRooms = HotelRepository.rooms.value;
    final listBookings = BookingRepository.bookings.value;

    double totalRevenue = 0.0;
    int completedBookings = 0;
    for (var b in listBookings) {
      if (b.status.name == "CONFIRMED" || b.status.name == "COMPLETED") {
        totalRevenue += b.totalAmount;
        completedBookings++;
      }
    }

    return {
      'revenue': totalRevenue,
      'bookingsCount': listBookings.length,
      'hotelsCount': listHotels.length,
      'roomsCount': listRooms.length,
      'activeBookings': completedBookings,
    };
  }

  void createAdminHotel(Hotel hotel) {
    HotelRepository.addHotel(hotel);
    notifyListeners();
  }

  void updateAdminHotel(Hotel hotel) {
    HotelRepository.updateHotel(hotel);
    notifyListeners();
  }

  void deleteAdminHotel(String hotelId) {
    HotelRepository.deleteHotel(hotelId);
    notifyListeners();
  }

  void createAdminRoom(Room room) {
    HotelRepository.addRoom(room);
    notifyListeners();
  }

  void deleteAdminRoom(String roomId) {
    HotelRepository.deleteRoom(roomId);
    notifyListeners();
  }
}
