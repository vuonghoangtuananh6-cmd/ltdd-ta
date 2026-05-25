import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../repositories/hotel_repository.dart';

class BookingSearchController extends ChangeNotifier {
  static final BookingSearchController _instance = BookingSearchController._internal();
  factory BookingSearchController() => _instance;
  BookingSearchController._internal() {
    HotelRepository.init();
  }

  String searchCity = "";
  String checkInDate = "2026-06-15";
  String checkOutDate = "2026-06-17";
  int nightsCount = 2;
  int guestsCount = 2;
  int roomsCount = 1;

  double filterPriceMin = 0.0;
  double filterPriceMax = 20000000.0;
  Set<int> filterStars = {};
  Set<String> filterAmenities = {};
  String searchSortOrder = "POPULAR"; // "POPULAR", "PRICE_ASC", "PRICE_DESC", "RATING_DESC"

  List<Hotel> get filteredHotels {
    List<Hotel> list = List<Hotel>.from(HotelRepository.hotels.value);

    // Filter City (case-insensitive substring)
    if (searchCity.isNotEmpty) {
      final query = searchCity.toLowerCase();
      list = list.where((h) => h.city.toLowerCase().contains(query) || h.name.toLowerCase().contains(query)).toList();
    }

    // Filter Price Min/Max
    list = list.where((h) => h.priceMin >= filterPriceMin && h.priceMin <= filterPriceMax).toList();

    // Filter Stars
    if (filterStars.isNotEmpty) {
      list = list.where((h) => filterStars.contains(h.stars)).toList();
    }

    // Filter Amenities (must contain all selected amenities)
    if (filterAmenities.isNotEmpty) {
      list = list.where((h) {
        return filterAmenities.every((amenity) => h.amenities.contains(amenity));
      }).toList();
    }

    // Sort order
    if (searchSortOrder == "PRICE_ASC") {
      list.sort((a, b) => a.priceMin.compareTo(b.priceMin));
    } else if (searchSortOrder == "PRICE_DESC") {
      list.sort((a, b) => b.priceMin.compareTo(a.priceMin));
    } else if (searchSortOrder == "RATING_DESC") {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  void submitBookingSearch({
    required String city,
    required String checkIn,
    required String checkOut,
    required int guests,
    required int rooms,
  }) {
    searchCity = city;
    checkInDate = checkIn;
    checkOutDate = checkOut;
    guestsCount = guests;
    roomsCount = rooms;

    // Add to recent searches in HotelRepository
    if (city.isNotEmpty && !HotelRepository.recentSearches.value.contains(city)) {
      HotelRepository.recentSearches.value = [city, ...HotelRepository.recentSearches.value];
    }

    // Compute nightsCount roughly (simple difference check)
    try {
      final inD = DateTime.parse(checkIn);
      final outD = DateTime.parse(checkOut);
      final diff = outD.difference(inD).inDays;
      nightsCount = diff > 0 ? diff : 1;
    } catch (_) {
      nightsCount = 1;
    }

    notifyListeners();
  }

  void resetFilters() {
    filterPriceMin = 0.0;
    filterPriceMax = 20000000.0;
    filterStars.clear();
    filterAmenities.clear();
    searchSortOrder = "POPULAR";
    notifyListeners();
  }

  void updateFilters({
    double? minPrice,
    double? maxPrice,
    Set<int>? stars,
    Set<String>? amenities,
    String? sortOrder,
  }) {
    if (minPrice != null) filterPriceMin = minPrice;
    if (maxPrice != null) filterPriceMax = maxPrice;
    if (stars != null) filterStars = stars;
    if (amenities != null) filterAmenities = amenities;
    if (sortOrder != null) searchSortOrder = sortOrder;
    notifyListeners();
  }

  void handleVoiceInput(String voiceText) {
    final result = HotelRepository.searchByVoiceMock(voiceText);
    searchCity = result;
    notifyListeners();
  }
}
