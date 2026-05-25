import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/coupon.dart';
import '../models/message.dart';
import '../repositories/user_repository.dart';
import '../repositories/hotel_repository.dart';

class HomeController extends ChangeNotifier {
  static final HomeController _instance = HomeController._internal();
  factory HomeController() => _instance;
  HomeController._internal() {
    UserRepository.init();
    HotelRepository.init();
  }

  User get currentUser => UserRepository.currentUser.value;
  ValueNotifier<User> get currentUserNotifier => UserRepository.currentUser;

  List<Coupon> get coupons => HotelRepository.coupons.value;
  ValueNotifier<List<Coupon>> get couponsNotifier => HotelRepository.coupons;

  List<Message> get chatMessages => HotelRepository.chatMessages.value;
  ValueNotifier<List<Message>> get chatMessagesNotifier => HotelRepository.chatMessages;

  List<String> get recentSearches => HotelRepository.recentSearches.value;
  ValueNotifier<List<String>> get recentSearchesNotifier => HotelRepository.recentSearches;

  void updateProfile(String name, String email, String phone) {
    UserRepository.updateProfile(name, email, phone);
    notifyListeners();
  }

  void updateAvatar(String path) {
    UserRepository.updateAvatarUrl(path);
    notifyListeners();
  }

  void setLanguage(String lang) {
    UserRepository.setLanguage(lang);
    notifyListeners();
  }

  void toggleDarkMode(bool enabled) {
    UserRepository.setDarkMode(enabled);
    notifyListeners();
  }

  void sendSupportChat(String message) {
    HotelRepository.addChatMessage(message);
    notifyListeners();
  }
}
