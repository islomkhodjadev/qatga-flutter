import 'package:boyshub/telegram_js.dart' as tg_js;

import 'dart:convert';

String? getTelegramChatId() {
  try {
    final user = tg_js.webApp.initDataUnsafe.user;
    if (user != null && user.id != null) {
      return user.id.toString();
    }
  } catch (e) {
    print('Telegram WebApp not found: $e');
  }
  return null;
}


String? getTelegramAllData() {
  try {
    final webApp = tg_js.webApp;
    final user = webApp.initDataUnsafe.user;

    // Create a Map with everything you want to show
    final map = {
      'id': user?.id,
      'username': user?.username,
      'first_name': user?.first_name,
      'last_name': user?.last_name,
      'themeParams': {
        'bg_color': webApp.themeParams.bg_color,
        'text_color': webApp.themeParams.text_color,
        'hint_color': webApp.themeParams.hint_color,
        'link_color': webApp.themeParams.link_color,
        'button_color': webApp.themeParams.button_color,
        'button_text_color': webApp.themeParams.button_text_color,
      },
      // You can add more properties from webApp or initDataUnsafe as needed
    };

    return const JsonEncoder.withIndent('  ').convert(map);
  } catch (e) {
    print('Telegram WebApp not found: $e');
    return null;
  }
}
