import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:boyshub/providers/auth_provider.dart';
import 'package:boyshub/providers/place_provider.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:boyshub/screens/intro_screen.dart';
import 'package:boyshub/providers/theme_provider.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';

String? getInitialLangFromUrl() {
  if (!kIsWeb) return null;
  try {
    final uri = Uri.parse(html.window.location.href);
    return uri.queryParameters['lang'];
  } catch (e) {
    print('Error parsing URL for language: $e');
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

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
  bool _langSet = false;
  bool _isLoading = true;
  String? _error;

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

        // Set up language
        await _setupLanguage();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeTelegramWebApp() async {
    try {
      // Initialize Telegram WebApp
      WebApp().init();

      // Wait a bit for WebApp to fully initialize
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if we have user data
      final tgUser = WebApp().initDataUnsafe.user;
      if (tgUser != null) {
        print('Telegram user initialized: ${tgUser.id}');

        // Show user info dialog after the widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUserInfoDialog(tgUser);
        });
      } else {
        print('No Telegram user data available');
      }
    } catch (e) {
      print('Error initializing Telegram WebApp: $e');
      // Don't throw here, continue without Telegram features
    }
  }

  Future<void> _setupLanguage() async {
    if (_langSet) return;

    try {
      final String? urlLang = getInitialLangFromUrl();
      if (urlLang != null && ['uz', 'ru', 'en'].contains(urlLang)) {
        if (mounted) {
          context.read<LanguageProvider>().setLang(urlLang);
        }
      }
      _langSet = true;
    } catch (e) {
      print('Error setting up language: $e');
    }
  }

  void _showUserInfoDialog(dynamic tgUser) {
    if (!mounted) return;

    final userInfo = '''
ID: ${tgUser.id}
Username: ${tgUser.username ?? '-'}
First Name: ${tgUser.firstName ?? '-'}
Last Name: ${tgUser.lastName ?? '-'}
Language: ${tgUser.languageCode ?? '-'}
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
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF1C77FF),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Color(0xFF1C77FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error screen if initialization failed
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  'Failed to initialize app',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, langProvider, _) {
        return MaterialApp(
          title: 'Qayerga boramiz?',
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
          theme: ThemeData(
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
              hintStyle: const TextStyle(
                color: Colors.black38,
              ),
              labelStyle: const TextStyle(
                color: Color(0xFF1C77FF),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xFF1C77FF),
              size: 26,
            ),
            dividerTheme: const DividerThemeData(
              color: Colors.black12,
              thickness: 1,
            ),
          ),
          darkTheme: ThemeData(
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
              hintStyle: const TextStyle(
                color: Colors.white54,
              ),
              labelStyle: const TextStyle(
                color: Color(0xFF1C77FF),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xFF1C77FF),
              size: 26,
            ),
            dividerTheme: const DividerThemeData(
              color: Colors.white12,
              thickness: 1,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const IntroScreen(),
        );
      },
    );
  }
}