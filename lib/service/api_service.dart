import 'dart:convert';
import 'dart:io';

class ApiService {
  static Future<List<Map<String, dynamic>>?> fetchHotelsFromApi() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('https://6a0c97985aa893e1015c1b6e.mockapi.io/hotels'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final rawJson = await response.transform(utf8.decoder).join();
        final list = jsonDecode(rawJson) as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      client.close();
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> fetchBookingsFromApi() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('https://6a0c97985aa893e1015c1b6e.mockapi.io/booking'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final rawJson = await response.transform(utf8.decoder).join();
        final list = jsonDecode(rawJson) as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      client.close();
    }
    return null;
  }
}
