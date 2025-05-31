import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:boyshub/services/api_service.dart'; // Import your ApiService

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

    // If web and running in Telegram WebApp
    if (kIsWeb) {
      try {
        final telegram = js.context['Telegram'];
        if (telegram != null) {
          final webApp = telegram['WebApp'];
          if (webApp != null) {
            final user = webApp['initDataUnsafe']['user'];
            if (user != null && user['id'] != null) {
              final chatId = user['id'];
              // Send to backend using ApiService
              await ApiService.post(
                'telegram/bot-clients/set-language/', // <-- your backend endpoint, e.g., /set_language/
                {
                  'chat_id': chatId,
                  'language': lang,
                },
              );
            }
          }
        }
      } catch (e) {
        print('Could not send chat_id to backend: $e');
      }
    }
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'uz';
    notifyListeners();
  }
}
