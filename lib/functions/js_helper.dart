import 'package:boyshub/telegram_js.dart' as tg_js;
import 'dart:convert';

String? getTelegramChatId() {
  try {
    final user = tg_js.webApp?.initDataUnsafe?.user;
    if (user != null) {
      return user.id.toString();
    }
  } catch (e) {
    print('Telegram WebApp not found or user.id not accessible: $e');
  }
  return null;
}

String? getTelegramAllData() {
  try {
    final webApp = tg_js.webApp;
    if (webApp == null) {
      print("webApp is null");
      return null;
    }

    final user = webApp.initDataUnsafe.user;
    final theme = webApp.themeParams;

    final map = {
      'id': user.id,
      'username': user.username,
      'first_name': user.first_name,
      'last_name': user.last_name,
      'themeParams': {
        'bg_color': theme.bg_color,
        'text_color': theme.text_color,
        'hint_color': theme.hint_color,
        'link_color': theme.link_color,
        'button_color': theme.button_color,
        'button_text_color': theme.button_text_color,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(map);
  } catch (e) {
    print('Error accessing Telegram WebApp data: $e');
    return null;
  }
}
