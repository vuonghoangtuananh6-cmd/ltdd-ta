import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class PrefsHelper {
  static final PrefsHelper _instance = PrefsHelper._internal();
  factory PrefsHelper() => _instance;
  PrefsHelper._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs;

  // Save User
  static void saveUser(User user) {
    _prefs.setString('current_user', jsonEncode(user.toJson()));
  }

  // Load User
  static User? loadUser() {
    final userStr = _prefs.getString('current_user');
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Generic methods
  static String? getString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  static bool? getBool(String key, {bool? defaultValue}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  static Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  static Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }
}
