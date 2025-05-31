import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:boyshub/providers/auth_provider.dart';
import 'package:boyshub/providers/place_provider.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:boyshub/screens/intro_screen.dart';
import 'package:boyshub/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  print('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // <<<<<<<< CHANGE THIS PART >>>>>>>>
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Qayerga boramiz?',
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              colorScheme: ColorScheme.light(
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
              appBarTheme: AppBarTheme(
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
              cardTheme: CardTheme(
                color: Color(0xFFFFFFFF),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              textTheme: TextTheme(
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
                  backgroundColor: Color(0xFF1C77FF),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
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
                  foregroundColor: Color(0xFF1C77FF),
                  side: BorderSide(color: Color(0xFF1C77FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF20DF7F),
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFFF0F4F8),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE0E6ED)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1C77FF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintStyle: TextStyle(
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                  color: Color(0xFF1C77FF),
                ),
              ),
              iconTheme: IconThemeData(
                color: Color(0xFF1C77FF),
                size: 26,
              ),
              dividerTheme: DividerThemeData(
                color: Colors.black12,
                thickness: 1,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF10141A),
              colorScheme: ColorScheme.dark(
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
              appBarTheme: AppBarTheme(
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
              cardTheme: CardTheme(
                color: Color(0xFF22262F),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              textTheme: TextTheme(
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
                  backgroundColor: Color(0xFF1C77FF),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
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
                  foregroundColor: Color(0xFF1C77FF),
                  side: BorderSide(color: Color(0xFF1C77FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF20DF7F),
                foregroundColor: Colors.black,
                elevation: 4,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFF181B20),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF22262F)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1C77FF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintStyle: TextStyle(
                  color: Colors.white54,
                ),
                labelStyle: TextStyle(
                  color: Color(0xFF1C77FF),
                ),
              ),
              iconTheme: IconThemeData(
                color: Color(0xFF1C77FF),
                size: 26,
              ),
              dividerTheme: DividerThemeData(
                color: Colors.white12,
                thickness: 1,
              ),
            ),
            themeMode: themeProvider.themeMode,  // <<--- Dynamic
            home: const IntroScreen(),
          );
        },
      ),
    );
  }
}
