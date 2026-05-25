import 'package:flutter/foundation.dart';
import '../service/prefs_helper.dart';

class FavoriteRepository {
  static final wishlist = ValueNotifier<Set<String>>({});
  static bool _isInitialized = false;

  static void init() {
    if (!_isInitialized) {
      final list = PrefsHelper.prefs.getStringList("wishlist_hotel_ids") ?? [];
      wishlist.value = list.toSet();
      _isInitialized = true;
    }
  }

  static void toggleWishlist(String hotelId) {
    final updated = Set<String>.from(wishlist.value);
    if (updated.contains(hotelId)) {
      updated.remove(hotelId);
    } else {
      updated.add(hotelId);
    }
    wishlist.value = updated;
    PrefsHelper.prefs.setStringList("wishlist_hotel_ids", updated.toList());
  }
}
