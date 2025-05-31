@JS('Telegram.WebApp')
library telegram_web_app;

import 'package:js/js.dart';
@JS()
@anonymous
class ThemeParamsJs {
  external String? get bg_color;
  external String? get text_color;
  external String? get hint_color;
  external String? get link_color;
  external String? get button_color;
  external String? get button_text_color;
  external factory ThemeParamsJs({
    String? bg_color,
    String? text_color,
    String? hint_color,
    String? link_color,
    String? button_color,
    String? button_text_color,
  });
}

@JS()
external WebAppJs get webApp;

@JS()
@anonymous
class WebAppJs {
  external WebAppInitDataJs get initDataUnsafe;
  external ThemeParamsJs get themeParams;
}

@JS()
@anonymous
class WebAppInitDataJs {
  external WebAppUserJs get user;
}

@JS()
@anonymous
class WebAppUserJs {
  external int get id;
  external String get username;
  external String get first_name;
  external String get last_name;
}
