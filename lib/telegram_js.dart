import 'dart:js' as js;

class TelegramWebApp {
  static dynamic get webApp => js.context['Telegram']['WebApp'];

  static dynamic get initDataUnsafe => webApp['initDataUnsafe'];
  static dynamic get themeParams => webApp['themeParams'];

  static dynamic get user => initDataUnsafe['user'];

  // Helper methods to access common properties
  static int get userId => user['id'] as int;
  static String get username => user['username'] as String;
  static String get firstName => user['first_name'] as String;
  static String get lastName => user['last_name'] as String;

  static String get bgColor => themeParams['bg_color'] as String;
  static String get textColor => themeParams['text_color'] as String;
  static String get buttonColor => themeParams['button_color'] as String;
}