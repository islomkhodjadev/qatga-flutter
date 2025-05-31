import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _lang = 'uz';

  String get lang => _lang;

  LanguageProvider() {
    _loadLang();
  }

  void setLang(String lang) async {
    _lang = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'uz';
    notifyListeners();
  }
}
