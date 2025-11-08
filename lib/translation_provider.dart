import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TranslationProvider with ChangeNotifier {
  String currentLanguage = "en";
  Map<String, String> _translations = {};
  String t(String key) => _translations[key] ?? key;
  Future<void> load(String locale) async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/translations/$locale"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // ✅ decode properly
        currentLanguage = locale;
        _translations = Map<String, String>.from(data['translations']);
        notifyListeners();
      } else {
        throw Exception("Translation fetch failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Translation error: $e");
    }
  }
  void toggleLanguage() {
    final newLang = currentLanguage == 'en' ? 'ar' : 'en';
    load(newLang);
  }
}
