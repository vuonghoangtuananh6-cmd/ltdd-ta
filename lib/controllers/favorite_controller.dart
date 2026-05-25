import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/hotel_repository.dart';

class FavoriteController extends ChangeNotifier {
  static final FavoriteController _instance = FavoriteController._internal();
  factory FavoriteController() => _instance;
  FavoriteController._internal() {
    FavoriteRepository.init();
    HotelRepository.init();
  }

  Set<String> get wishlist => FavoriteRepository.wishlist.value;
  ValueNotifier<Set<String>> get wishlistNotifier => FavoriteRepository.wishlist;

  List<Hotel> get wishlistHotels {
    final list = HotelRepository.hotels.value;
    final ids = wishlist;
    return list.where((it) => ids.contains(it.id)).toList();
  }

  void toggleWishlist(String hotelId) {
    FavoriteRepository.toggleWishlist(hotelId);
    notifyListeners();
  }

  bool isFavorite(String hotelId) {
    return wishlist.contains(hotelId);
  }
}
