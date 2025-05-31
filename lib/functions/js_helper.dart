import 'dart:js' as js;
import 'package:flutter/foundation.dart'; // for kIsWeb

String? getTelegramChatIdJs() {
  if (!kIsWeb) return null;
  try {
    final telegram = js.context['Telegram'];
    final webApp = telegram?['WebApp'];
    final initDataUnsafe = webApp?['initDataUnsafe'];
    final user = initDataUnsafe?['user'];
    final id = user?['id'];
    if (id != null) return id.toString();
  } catch (e) {
    // ignore, just return null if not inside telegram
  }
  return null;
}
