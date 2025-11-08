import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String baseUrl = "http://10.0.2.2:8000"; // ✅ Use your actual server URL if deployed

  Future<Map<String, String>> fetchTranslations(String locale) async {
    final response = await http.get(Uri.parse('$baseUrl/translations/$locale'));

    if (response.statusCode == 200) {
      final jsonString = utf8.decode(response.bodyBytes); // decode Arabic correctly
      final json = jsonDecode(jsonString);
      return Map<String, String>.from(json['translations']);
    } else {
      throw Exception("Failed to load translations for $locale");
    }
  }
}
