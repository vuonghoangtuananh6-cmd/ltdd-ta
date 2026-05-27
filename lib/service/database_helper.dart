import 'dart:convert';
import 'prefs_helper.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/coupon.dart';

class DatabaseHelper {
  static Future<void> initDatabase() async {
    // Initialise default dataset if empty
    if (PrefsHelper.getString('saved_hotels') == null) {
      // Seeding is handled gracefully by high-level repositories
    }
  }

  static void saveList<T>(String key, List<T> list, Map<String, dynamic> Function(T) toJson) {
    try {
      final listJson = list.map((item) => toJson(item)).toList();
      PrefsHelper.setString(key, jsonEncode(listJson));
    } catch (e) {
      print("DatabaseHelper Error saving $key: $e");
    }
  }

  static List<T> loadList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final strStr = PrefsHelper.getString(key);
    if (strStr == null) return [];
    try {
      final list = jsonDecode(strStr) as List;
      return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print("DatabaseHelper Error loading $key: $e");
      return [];
    }
  }

  // Load / save specific logic for convenience
  static void saveHotels(List<Hotel> list) => saveList<Hotel>('saved_hotels', list, (item) => item.toJson());
  static List<Hotel> loadHotels() => loadList<Hotel>('saved_hotels', (json) => Hotel.fromJson(json));

  static void saveRooms(List<Room> list) => saveList<Room>('saved_rooms', list, (item) => item.toJson());
  static List<Room> loadRooms() => loadList<Room>('saved_rooms', (json) => Room.fromJson(json));

  static void saveBookings(List<Booking> list) => saveList<Booking>('saved_bookings', list, (item) => item.toJson());
  static List<Booking> loadBookings() => loadList<Booking>('saved_bookings', (json) => Booking.fromJson(json));

  static void saveReviews(List<Review> list) => saveList<Review>('saved_reviews', list, (item) => item.toJson());
  static List<Review> loadReviews() => loadList<Review>('saved_reviews', (json) => Review.fromJson(json));

  static void saveCoupons(List<Coupon> list) => saveList<Coupon>('saved_coupons', list, (item) => item.toJson());
  static List<Coupon> loadCoupons() => loadList<Coupon>('saved_coupons', (json) => Coupon.fromJson(json));

  static void saveWishlist(Set<String> list) {
    PrefsHelper.setStringList('wishlist_hotel_ids', list.toList());
  }
  static Set<String> loadWishlist() {
    final list = PrefsHelper.getStringList('wishlist_hotel_ids') ?? [];
    return list.toSet();
  }

  static void saveRecentSearches(List<String> list) {
    PrefsHelper.setStringList('recent_searches', list);
  }
  static List<String> loadRecentSearches() {
    return PrefsHelper.getStringList('recent_searches') ?? ["Hà Nội", "Đà Nẵng", "Phú Quốc"];
  }
}
