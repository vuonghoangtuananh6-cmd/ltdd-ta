// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryMedium = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryBackground = Color(0xFFF7F9FC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);

  static const Color orange = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFF0FDF4);
  static const Color purple = Color(0xFF9333EA);
  static const Color purpleLight = Color(0xFFFAF5FF);
}

class AppConstants {
  static const String appName = 'StayEase';
  static const String prefsKey = 'StayEase_Prefs';

  // Common Key Strings inside SharedPreferences / Storage
  static const String keyCurrentUser = 'current_user';
  static const String keyFavorites = 'favorites_list';
  static const String keyBookings = 'bookings_list';
  static const String keyLanguage = 'app_language';
  static const String keyIsDarkMode = 'is_dark_mode';
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify_email';
  static const String forgotPassword = '/forgot_password';
  static const String main = '/main';
  static const String hotelDetail = '/hotel_detail';
  static const String checkout = '/checkout';
  static const String chat = '/chat';
  static const String editProfile = '/edit_profile';
  static const String changePassword = '/change_password';
  static const String admin = '/admin';
  static const String wishlist = '/wishlist';
}
