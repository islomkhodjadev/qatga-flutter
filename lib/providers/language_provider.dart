import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:boyshub/services/api_service.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';

class LanguageProvider with ChangeNotifier {
  String _lang = 'uz';
  bool _isLoading = false;

  String get lang => _lang;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _loadLang();
  }

  Future<void> setLang(String lang) async {
    if (_lang == lang) return; // Don't change if it's the same language

    _isLoading = true;
    notifyListeners();

    try {
      _lang = lang;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', lang);

      // Update language on server if running as Telegram Mini App
      if (kIsWeb) {
        await _updateLanguageOnServer(lang);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error setting language: $e");
      _isLoading = false;
      notifyListeners();
      // Optionally rethrow if you want to handle errors in UI
      // rethrow;
    }
  }

  Future<void> _updateLanguageOnServer(String lang) async {
    try {
      final user = WebApp().initDataUnsafe.user;
      if (user?.id != null) {
        final chatId = user!.id.toString();

        await Future.any([
          ApiService.post(
            'bot-clients/set-language/',
            {'chat_id': chatId, 'language': lang},
          ),
          Future.delayed(const Duration(seconds: 10), () => throw TimeoutException('Request timed out')),
        ]);

        print("Language updated on server: $lang");
      } else {
        print("Telegram user ID not available - skipping server update");
      }
    } catch (e) {
      print("Failed to update language on server: $e");
      // Don't throw here - language change should still work locally
    }
  }

  Future<void> _loadLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('app_language');

      if (savedLang != null && ['uz', 'ru', 'en'].contains(savedLang)) {
        _lang = savedLang;
      } else {
        // Try to get language from Telegram user if available
        if (kIsWeb) {
          await _loadLanguageFromTelegram();
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error loading language: $e");
      // Keep default language 'uz'
      notifyListeners();
    }
  }

  Future<void> _loadLanguageFromTelegram() async {
    try {
      final user = WebApp().initDataUnsafe.user;
      final telegramLang = user?.languageCode;

      if (telegramLang != null) {
        // Map Telegram language codes to supported languages
        String mappedLang;
        switch (telegramLang.toLowerCase()) {
          case 'ru':
            mappedLang = 'ru';
            break;
          case 'en':
            mappedLang = 'en';
            break;
          case 'uz':
          default:
            mappedLang = 'uz';
            break;
        }

        if (['uz', 'ru', 'en'].contains(mappedLang)) {
          _lang = mappedLang;

          // Save the detected language
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_language', mappedLang);

          print("Language detected from Telegram: $mappedLang");
        }
      }
    } catch (e) {
      print("Error getting language from Telegram: $e");
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}