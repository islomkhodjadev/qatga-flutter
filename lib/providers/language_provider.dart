import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:boyshub/services/api_service.dart';

import 'package:boyshub/functions/js_helper.dart'; // Import your ApiService

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

    // Only on web, send Telegram chat_id to backend
    if (kIsWeb) {
      final chatId = await getTelegramChatIdJs();
      if (chatId != null) {
        await ApiService.post(
          'bot-clients/set-language/',
          {'chat_id': chatId, 'language': lang},
        );
      }
    }
  }


  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'uz';
    notifyListeners();
  }
}
