import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:boyshub/services/api_service.dart';
import 'package:boyshub/telegram_provider.dart'; // Adjust path as needed

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
    }
  }

  Future<void> _updateLanguageOnServer(String lang) async {
    try {
      final tgApp = TelegramWebApp.instance;

      if (tgApp.isAvailable) {
        final userId = tgApp.userId;

        if (userId != null) {
          final chatId = userId.toString();

          // Set a timeout for the API call
          await Future.any([
            ApiService.post(
              'telegram/bot-clients/set-language/',
              {'chat_id': chatId, 'language': lang},
            ),
            Future.delayed(const Duration(seconds: 10), () => throw TimeoutException('Request timed out')),
          ]);

          print("Language updated on server: $lang for user: $chatId");
        } else {
          print("Telegram user ID not available - skipping server update");
        }
      } else {
        print("Telegram WebApp not available - skipping server update");
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
      final tgApp = TelegramWebApp.instance;

      if (tgApp.isAvailable) {
        final userData = tgApp.getUserData();
        final telegramLang = userData?['language_code'] as String?;

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
      }
    } catch (e) {
      print("Error getting language from Telegram: $e");
    }
  }

  // Helper method to get current user's Telegram data
  Map<String, dynamic>? getTelegramUserData() {
    if (!kIsWeb) return null;

    try {
      final tgApp = TelegramWebApp.instance;
      return tgApp.isAvailable ? tgApp.getUserData() : null;
    } catch (e) {
      print("Error getting Telegram user data: $e");
      return null;
    }
  }

  // Check if running in Telegram
  bool get isRunningInTelegram {
    if (!kIsWeb) return false;
    return TelegramWebApp.instance.isAvailable;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}