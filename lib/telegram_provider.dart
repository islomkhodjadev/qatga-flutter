import 'dart:js' as js;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class TelegramWebApp {
  static TelegramWebApp? _instance;
  static TelegramWebApp get instance => _instance ??= TelegramWebApp._();

  TelegramWebApp._();

  // Check if Telegram WebApp is available
  bool get isAvailable {
    if (!kIsWeb) return false;
    try {
      return js.context.hasProperty('Telegram') &&
          js.context['Telegram'] != null &&
          js.context['Telegram'].hasProperty('WebApp');
    } catch (e) {
      print('Error checking Telegram availability: $e');
      return false;
    }
  }

  // Initialize Telegram WebApp
  void init() {
    if (!isAvailable) {
      print('Telegram WebApp not available');
      return;
    }

    try {
      js.context['Telegram']['WebApp'].callMethod('ready');
      js.context['Telegram']['WebApp'].callMethod('expand');
      print('Telegram WebApp initialized successfully');
    } catch (e) {
      print('Error initializing Telegram WebApp: $e');
    }
  }

  // Get user data
  Map<String, dynamic>? getUserData() {
    if (!isAvailable) return null;

    try {
      final webApp = js.context['Telegram']['WebApp'];
      final initDataUnsafe = webApp['initDataUnsafe'];

      if (initDataUnsafe == null) {
        print('No initDataUnsafe available');
        return null;
      }

      final user = initDataUnsafe['user'];
      if (user == null) {
        print('No user data in initDataUnsafe');
        return null;
      }

      // Convert JS object to Dart Map
      final userData = <String, dynamic>{};

      // Helper function to safely get property
      dynamic getProperty(dynamic obj, String prop) {
        try {
          return obj[prop];
        } catch (e) {
          return null;
        }
      }

      userData['id'] = getProperty(user, 'id');
      userData['first_name'] = getProperty(user, 'first_name');
      userData['last_name'] = getProperty(user, 'last_name');
      userData['username'] = getProperty(user, 'username');
      userData['language_code'] = getProperty(user, 'language_code');
      userData['is_premium'] = getProperty(user, 'is_premium') ?? false;
      userData['photo_url'] = getProperty(user, 'photo_url');

      print('User data retrieved: $userData');
      return userData;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get init data (raw)
  String? getInitData() {
    if (!isAvailable) return null;

    try {
      final webApp = js.context['Telegram']['WebApp'];
      return webApp['initData']?.toString();
    } catch (e) {
      print('Error getting init data: $e');
      return null;
    }
  }

  // Get theme params
  Map<String, dynamic>? getThemeParams() {
    if (!isAvailable) return null;

    try {
      final webApp = js.context['Telegram']['WebApp'];
      final themeParams = webApp['themeParams'];

      if (themeParams == null) return null;

      final theme = <String, dynamic>{};

      // Helper function to safely get color property
      String? getColor(dynamic obj, String prop) {
        try {
          return obj[prop]?.toString();
        } catch (e) {
          return null;
        }
      }

      theme['bg_color'] = getColor(themeParams, 'bg_color');
      theme['text_color'] = getColor(themeParams, 'text_color');
      theme['hint_color'] = getColor(themeParams, 'hint_color');
      theme['link_color'] = getColor(themeParams, 'link_color');
      theme['button_color'] = getColor(themeParams, 'button_color');
      theme['button_text_color'] = getColor(themeParams, 'button_text_color');
      theme['secondary_bg_color'] = getColor(themeParams, 'secondary_bg_color');

      return theme;
    } catch (e) {
      print('Error getting theme params: $e');
      return null;
    }
  }

  // Check if user is premium
  bool get isUserPremium {
    final userData = getUserData();
    return userData?['is_premium'] == true;
  }

  // Get user language
  String? get userLanguage {
    final userData = getUserData();
    return userData?['language_code'];
  }

  // Get user ID
  int? get userId {
    final userData = getUserData();
    final id = userData?['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  // Close the mini app
  void close() {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp'].callMethod('close');
    } catch (e) {
      print('Error closing Telegram WebApp: $e');
    }
  }

  // Show main button
  void showMainButton(String text, {Function? onTap}) {
    if (!isAvailable) return;

    try {
      final mainButton = js.context['Telegram']['WebApp']['MainButton'];
      mainButton['text'] = text;
      mainButton.callMethod('show');

      if (onTap != null) {
        mainButton.callMethod('onClick', [js.allowInterop(() => onTap())]);
      }
    } catch (e) {
      print('Error showing main button: $e');
    }
  }

  // Hide main button
  void hideMainButton() {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp']['MainButton'].callMethod('hide');
    } catch (e) {
      print('Error hiding main button: $e');
    }
  }

  // Show alert
  void showAlert(String message) {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp'].callMethod('showAlert', [message]);
    } catch (e) {
      print('Error showing alert: $e');
    }
  }

  // Show confirm
  void showConfirm(String message, Function(bool) callback) {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp'].callMethod('showConfirm', [
        message,
        js.allowInterop((bool result) => callback(result))
      ]);
    } catch (e) {
      print('Error showing confirm: $e');
    }
  }

  // Enable/disable closing confirmation
  void enableClosingConfirmation() {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp'].callMethod('enableClosingConfirmation');
    } catch (e) {
      print('Error enabling closing confirmation: $e');
    }
  }

  void disableClosingConfirmation() {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp'].callMethod('disableClosingConfirmation');
    } catch (e) {
      print('Error disabling closing confirmation: $e');
    }
  }

  // Get viewport info
  Map<String, dynamic>? getViewport() {
    if (!isAvailable) return null;

    try {
      final webApp = js.context['Telegram']['WebApp'];
      return {
        'height': webApp['viewportHeight'],
        'stable_height': webApp['viewportStableHeight'],
        'is_expanded': webApp['isExpanded'],
      };
    } catch (e) {
      print('Error getting viewport info: $e');
      return null;
    }
  }

  // Send data to bot
  void sendData(String data) {
    if (!isAvailable) return;

    try {
      js.context['Telegram']['WebApp'].callMethod('sendData', [data]);
    } catch (e) {
      print('Error sending data: $e');
    }
  }
}