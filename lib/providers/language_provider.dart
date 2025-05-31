import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:boyshub/services/api_service.dart';

import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';

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

    if (kIsWeb) {
      try {
        final user = WebApp().initDataUnsafe.user;
        if (user != null && user.id != null) {
          final chatId = user.id.toString();
          await ApiService.post(
            'bot-clients/set-language/',
            {'chat_id': chatId, 'language': lang},
          );
        }
      } catch (e) {
        print("Telegram user ID not available: $e");
      }
    }
  }




  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'uz';
    notifyListeners();
  }
}
