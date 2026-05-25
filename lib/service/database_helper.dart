import 'dart:convert';
import 'prefs_helper.dart';

class DatabaseHelper {
  static Future<void> initDatabase() async {
    // Initialise default dataset if empty
    if (PrefsHelper.getString('saved_hotels') == null) {
      // SharedPreferences is set up
    }
  }

  static void saveList<T>(String key, List<T> list, Map<String, dynamic> Function(T) toJson) {
    final listJson = list.map((item) => toJson(item)).toList();
    PrefsHelper.setString(key, jsonEncode(listJson));
  }

  static List<T> loadList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final strStr = PrefsHelper.getString(key);
    if (strStr == null) return [];
    try {
      final list = jsonDecode(strStr) as List;
      return list.map((item) => fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
