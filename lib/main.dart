import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:boyshub/providers/auth_provider.dart';
import 'package:boyshub/providers/place_provider.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:boyshub/screens/intro_screen.dart';
import 'package:boyshub/providers/theme_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:boyshub/telegram_provider.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boyshub/screens/places/home_screen.dart';
import 'package:boyshub/screens/intro_screen.dart';

// Global splash screen widget for consistent loading experience
class AppSplashScreen extends StatelessWidget {
  final String message;

  const AppSplashScreen({
    super.key,
    this.message = 'Loading...'
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C77FF).withOpacity(0.1),
                      spreadRadius: 20,
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF1C77FF),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF1C77FF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please wait...',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InitialScreenDecider extends StatefulWidget {
  const InitialScreenDecider({super.key});

  @override
  State<InitialScreenDecider> createState() => _InitialScreenDeciderState();
}

class _InitialScreenDeciderState extends State<InitialScreenDecider> {
  bool? _introSeen;

  @override
  void initState() {
    super.initState();
    _loadSeen();
  }

  Future<void> _loadSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('intro_seen') ?? false;
      if (mounted) {
        setState(() {
          _introSeen = seen;
        });
      }
    } catch (e) {
      print('Error loading intro seen: $e');
      if (mounted) {
        setState(() {
          _introSeen = false; // Default to showing intro on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_introSeen == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1C77FF),
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Initializing...',
                style: TextStyle(
                  color: Color(0xFF1C77FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _introSeen == true ? const HomeScreen() : const IntroScreen();
  }
}

String? getInitialLangFromUrl() {
  if (!kIsWeb) return null;
  try {
    final uri = Uri.base;
    return uri.queryParameters['lang'];
  } catch (e) {
    print('Error parsing URL for language: $e');
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment first
  try {
    await dotenv.load(fileName: ".env");
    print('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize providers and run main app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  String? _error;
  Map<String, dynamic>? _telegramUserData;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (kIsWeb) {
        // Initialize Telegram WebApp first
        await _initializeTelegramWebApp();
        // Set up language after getting Telegram data
        await _setupLanguage();
      } else {
        // For non-web platforms, just setup language
        await _setupLanguage();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _initializeTelegramWebApp() async {
    try {
      final tgApp = TelegramWebApp.instance;

      if (tgApp.isAvailable) {
        print('Telegram WebApp is available');
        tgApp.init();

        _telegramUserData = tgApp.getUserData();

        if (_telegramUserData != null) {
          print('Telegram user data: $_telegramUserData');
          // Show user info dialog after a delay to not block UI
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showUserInfoDialog();
          });
        }

        final themeParams = tgApp.getThemeParams();
        if (themeParams != null) {
          print('Telegram theme params: $themeParams');
        }
      } else {
        print('Telegram WebApp not available - running in regular web mode');
      }
    } catch (e) {
      print('Error initializing Telegram WebApp: $e');
      // Continue without Telegram features
    }
  }

  Future<void> _setupLanguage() async {
    try {
      String? selectedLang;

      // Priority 1: URL parameter
      selectedLang = getInitialLangFromUrl();

      // Priority 2: Telegram user language
      if (selectedLang == null && _telegramUserData != null) {
        final tgLang = _telegramUserData!['language_code'] as String?;
        if (tgLang != null) {
          switch (tgLang.toLowerCase()) {
            case 'ru':
              selectedLang = 'ru';
              break;
            case 'en':
              selectedLang = 'en';
              break;
            case 'uz':
            default:
              selectedLang = 'uz';
              break;
          }
        }
      }

      // Set default language if none found
      selectedLang ??= 'uz';

      if (['uz', 'ru', 'en'].contains(selectedLang)) {
        if (mounted) {
          context.read<LanguageProvider>().setLang(selectedLang);
        }
      }
    } catch (e) {
      print('Error setting up language: $e');
      // Set default language on error
      if (mounted) {
        context.read<LanguageProvider>().setLang('uz');
      }
    }
  }

  void _showUserInfoDialog() {
    if (!mounted || _telegramUserData == null) return;

    final userInfo = '''
ID: ${_telegramUserData!['id'] ?? '-'}
Username: ${_telegramUserData!['username'] ?? '-'}
First Name: ${_telegramUserData!['first_name'] ?? '-'}
Last Name: ${_telegramUserData!['last_name'] ?? '-'}
Language: ${_telegramUserData!['language_code'] ?? '-'}
Premium: ${_telegramUserData!['is_premium'] == true ? 'Yes' : 'No'}
''';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Telegram User Data"),
        content: SelectableText(userInfo),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_isInitialized) {
      return const AppSplashScreen(message: 'Setting up...');
    }

    // Show error message but continue with app
    if (_error != null) {
      // Show error briefly then continue
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: ${_error!}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }

    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, langProvider, _) {
        return MaterialApp(
          title: 'Qayerga boramiz?',
          debugShowCheckedModeBanner: false,
          locale: Locale(langProvider.lang),
          supportedLocales: const [
            Locale('uz'),
            Locale('ru'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const InitialScreenDecider(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1C77FF),
        secondary: Color(0xFF20DF7F),
        background: Color(0xFFF8FAFC),
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.black87,
        onSurface: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF1C77FF)),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1,
        ),
      ),
      cardTheme: const CardTheme(
        color: Color(0xFFFFFFFF),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: Colors.black54),
        headlineSmall: TextStyle(
          color: Color(0xFF1C77FF),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF20DF7F),
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C77FF),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1C77FF),
          side: const BorderSide(color: Color(0xFF1C77FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF20DF7F),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1C77FF), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: const TextStyle(color: Colors.black38),
        labelStyle: const TextStyle(color: Color(0xFF1C77FF)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1C77FF), size: 26),
      dividerTheme: const DividerThemeData(color: Colors.black12, thickness: 1),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF10141A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1C77FF),
        secondary: Color(0xFF20DF7F),
        background: Color(0xFF10141A),
        surface: Color(0xFF22262F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white70,
        onSurface: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF10141A),
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF1C77FF)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1,
        ),
      ),
      cardTheme: const CardTheme(
        color: Color(0xFF22262F),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: Colors.white70),
        headlineSmall: TextStyle(
          color: Color(0xFF1C77FF),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF20DF7F),
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C77FF),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1C77FF),
          side: const BorderSide(color: Color(0xFF1C77FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF20DF7F),
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF181B20),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF22262F)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1C77FF), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Color(0xFF1C77FF)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1C77FF), size: 26),
      dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
    );
  }
}