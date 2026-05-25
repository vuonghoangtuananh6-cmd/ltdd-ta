import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../service/prefs_helper.dart';

class UserRepository {
  static final currentUser = ValueNotifier<User>(User());
  static bool _isInitialized = false;

  static void init() {
    if (!_isInitialized) {
      final savedUser = PrefsHelper.loadUser();
      if (savedUser != null) {
        final finalUser = savedUser.email.trim().toLowerCase() == "vuonghoangtuananh6@gmail.com"
            ? savedUser.copyWith(role: "ADMIN")
            : savedUser;
        currentUser.value = finalUser;
      } else {
        currentUser.value = User();
      }
      _isInitialized = true;
    }
  }

  static void saveUser() {
    PrefsHelper.saveUser(currentUser.value);
  }

  static String getPassword(String email) {
    final emailClean = email.trim().toLowerCase();
    return PrefsHelper.prefs.getString("password_$emailClean") ?? "123456";
  }

  static void savePassword(String email, String pass) {
    final emailClean = email.trim().toLowerCase();
    PrefsHelper.prefs.setString("password_$emailClean", pass);
  }

  static User registerUserAccount(String name, String email, String phone, String pass) {
    final emailClean = email.trim().toLowerCase();
    final isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com";
    final newUser = User(
      id: "user_${const Uuid().v4().substring(0, 5)}",
      email: email,
      name: name,
      phoneNumber: phone,
      loyaltyPoints: 500,
      isVerified: isKeyAdmin,
      createdAt: DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
      role: isKeyAdmin ? "ADMIN" : "USER",
    );
    currentUser.value = newUser;
    saveUser();
    savePassword(emailClean, pass);
    PrefsHelper.prefs.setString("profile_name_$emailClean", name);
    PrefsHelper.prefs.setString("profile_phone_$emailClean", phone);
    PrefsHelper.prefs.setBool("verified_$emailClean", isKeyAdmin);
    return newUser;
  }

  static bool isEmailVerified(String email) {
    final emailClean = email.trim().toLowerCase();
    if (emailClean == "vuonghoangtuananh6@gmail.com") return true;
    return PrefsHelper.prefs.getBool("verified_$emailClean") ?? false;
  }

  static void markEmailVerified(String email) {
    final emailClean = email.trim().toLowerCase();
    PrefsHelper.prefs.setBool("verified_$emailClean", true);
    if (currentUser.value.email.trim().toLowerCase() == emailClean) {
      currentUser.value = currentUser.value.copyWith(isVerified: true);
      saveUser();
    }
  }

  static bool loginUserAccount(String email, String pass) {
    final emailClean = email.trim().toLowerCase();
    final savedPass = getPassword(emailClean);
    if (savedPass == pass) {
      final name = PrefsHelper.prefs.getString("profile_name_$emailClean") ?? "Vương Hoàng Tuấn Anh";
      final phone = PrefsHelper.prefs.getString("profile_phone_$emailClean") ?? "0987654321";
      final isVerifiedStatus = isEmailVerified(emailClean);
      final isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com";
      final loadedUser = User(
        id: "user_${emailClean.hashCode.toString().substring(0, 5)}",
        email: emailClean,
        name: name,
        phoneNumber: phone,
        loyaltyPoints: 450,
        isVerified: isVerifiedStatus,
        createdAt: "2026-05-23",
        role: isKeyAdmin ? "ADMIN" : "USER",
      );
      currentUser.value = loadedUser;
      saveUser();
      return true;
    }
    return false;
  }

  static void googleSignInAccount(String email, String name, String avatarUrl) {
    final emailClean = email.trim().toLowerCase();
    final isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com";
    final newUser = User(
      id: "google_${const Uuid().v4().substring(0, 5)}",
      email: emailClean,
      name: name,
      avatarUrl: avatarUrl,
      loyaltyPoints: 500,
      isVerified: true,
      createdAt: DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
      role: isKeyAdmin ? "ADMIN" : "USER",
    );
    currentUser.value = newUser;
    saveUser();
    PrefsHelper.prefs.setString("profile_name_$emailClean", name);
    PrefsHelper.prefs.setString("profile_phone_$emailClean", "0987654321");
    PrefsHelper.prefs.setBool("verified_$emailClean", true);
  }

  static void updateProfile(String name, String email, String phone) {
    currentUser.value = currentUser.value.copyWith(name: name, email: email, phoneNumber: phone);
    saveUser();
  }

  static void updateAvatarUrl(String url) {
    currentUser.value = currentUser.value.copyWith(avatarUrl: url);
    saveUser();
  }

  static void setLanguage(String lang) {
    currentUser.value = currentUser.value.copyWith(language: lang);
    saveUser();
  }

  static void setDarkMode(bool enabled) {
    currentUser.value = currentUser.value.copyWith(isDarkMode: enabled);
    saveUser();
  }

  static void rewardLoyaltyPoints(int pts) {
    currentUser.value = currentUser.value.copyWith(loyaltyPoints: currentUser.value.loyaltyPoints + pts);
    saveUser();
  }
}
