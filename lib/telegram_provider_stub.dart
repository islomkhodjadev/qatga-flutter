class TelegramWebApp {
  static final instance = TelegramWebApp();

  bool get isAvailable => false;

  void init() {}
  Map<String, dynamic>? getUserData() => null;
  String? getInitData() => null;
  Map<String, dynamic>? getThemeParams() => null;
  bool get isUserPremium => false;
  String? get userLanguage => null;
  int? get userId => null;
  void close() {}
  void showMainButton(String text, {Function? onTap}) {}
  void hideMainButton() {}
  void showAlert(String message) {}
  void showConfirm(String message, Function(bool) callback) {}
  void enableClosingConfirmation() {}
  void disableClosingConfirmation() {}
  Map<String, dynamic>? getViewport() => null;
  void sendData(String data) {}
}
