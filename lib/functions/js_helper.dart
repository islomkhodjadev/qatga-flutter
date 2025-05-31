import 'dart:js' as js;
import 'package:flutter/foundation.dart';

String? getTelegramChatIdJs() {
  if (!kIsWeb) return null;
  try {
    final telegram = js.context['Telegram'];
    if (telegram == null) {
      print('Telegram JS object is null (not in Telegram WebApp?)');
      return null;
    }
    final webApp = telegram['WebApp'];
    if (webApp == null) {
      print('Telegram.WebApp is null');
      return null;
    }
    final initDataUnsafe = webApp['initDataUnsafe'];
    if (initDataUnsafe == null) {
      print('Telegram.WebApp.initDataUnsafe is null');
      return null;
    }
    final user = initDataUnsafe['user'];
    if (user == null) {
      print('Telegram.WebApp.initDataUnsafe.user is null');
      return null;
    }
    final id = user['id'];
    if (id == null) {
      print('User ID is null');
      return null;
    }
    return id.toString();
  } catch (e) {
    print('Error accessing Telegram JS: $e');
    return null;
  }
}
