import 'package:flutter/foundation.dart';
import '../service/prefs_helper.dart';

class FavoriteRepository {
  static final wishlist = ValueNotifier<Set<String>>({});
  static bool _isInitialized = false;

  static void init() {
    if (!_isInitialized) {
      loadWishlist();
      _isInitialized = true;
    }
  }

  static void loadWishlist() {
    final list = PrefsHelper.prefs.getStringList("wishlist_hotel_ids") ?? [];
    wishlist.value = list.toSet();
  }

  static void saveWishlist() {
    PrefsHelper.prefs.setStringList("wishlist_hotel_ids", wishlist.value.toList());
  }

  static void toggleWishlist(String hotelId) {
    final updated = Set<String>.from(wishlist.value);
    if (updated.contains(hotelId)) {
      updated.remove(hotelId);
    } else {
      updated.add(hotelId);
    }
    wishlist.value = updated;
    saveWishlist();
  }
}
