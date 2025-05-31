import 'package:boyshub/telegram_js.dart' as tg_js;

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
