import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:boyshub/screens/places/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final Map<String, List<String>> texts = {
    'uz': [
      "BARCHA TOIFADAGI JOYLAR",
      "ENG YAQIN JOYNI TANLA",
      "JOY HAQIDAGI TO'LIQ MA'LUMOT",
      "SERVIS VA NARXLAR",
      "TANLA, YOQTIR VA BOR\nBUGUN QATGA?"
    ],
    'ru': [
      "МЕСТА ВСЕХ КАТЕГОРИЙ",
      "ВЫБЕРИТЕ БЛИЖАЙШЕЕ МЕСТО",
      "ПОДРОБНАЯ ИНФОРМАЦИЯ О МЕСТЕ",
      "СЕРВИС И ЦЕНЫ",
      "ВЫБЕРИ, ОЦЕНИ И ПОСЕТИ\nКУДА СЕГОДНЯ?"
    ],
    'en': [
      "ALL TYPES OF PLACES",
      "CHOOSE THE NEAREST PLACE",
      "DETAILED INFO ABOUT THE PLACE",
      "SERVICES AND PRICES",
      "CHOOSE, LIKE AND GO\nWHERE TO TODAY?"
    ],
  };

  final buttonLabels = {
    'skip': {
      'uz': "O‘tkazib yuborish",
      'ru': "Пропустить",
      'en': "Skip"
    },
    'next': {
      'uz': "Keyingi",
      'ru': "Далее",
      'en': "Next"
    },
    'start': {
      'uz': "Boshlash",
      'ru': "Начать",
      'en': "Start"
    }
  };

  final List<String> images = [
    'assets/icon11.webp',
    'assets/icon22.webp',
    'assets/icon33.webp',
    'assets/icon44.webp',
    '', // Last page: no image
  ];

  void _goNext() {
    if (_currentPage < images.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntro();
    }
  }

  void _finishIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Provider.of<LanguageProvider>(context).lang;
    final blue = const Color(0xFF1C77FF);
    final Color dotActive = blue;
    final Color dotInactive = Colors.white24;
    final pageTexts = texts[lang] ?? texts['uz']!;

    final double imageMaxWidth = MediaQuery.of(context).size.width * 0.85;
    final double imageHeight = imageMaxWidth * 16 / 9; // 9:16 portrait ratio

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 38),
                          // Main text above image
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
                            child: Text(
                              pageTexts[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: index == images.length - 1 ? 26 : 22,
                                color: blue,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          // Image area: always same ratio, never cropped
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: AspectRatio(
                                aspectRatio: 9 / 16,
                                child: images[index].isNotEmpty
                                    ? Image.asset(
                                  images[index],
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                )
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ),
                  );
                },
              ),
            ),
            // Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: _currentPage == index ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? dotActive : dotInactive,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  if (_currentPage < images.length - 1)
                    TextButton(
                      onPressed: _finishIntro,
                      style: TextButton.styleFrom(
                        foregroundColor: blue,
                      ),
                      child: Text(
                        buttonLabels['skip']![lang] ?? buttonLabels['skip']!['uz']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  else
                    const SizedBox(width: 120), // alignment on last page
                  // Next / Start button
                  SizedBox(
                    width: 120,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == images.length - 1
                            ? buttonLabels['start']![lang] ?? buttonLabels['start']!['uz']!
                            : buttonLabels['next']![lang] ?? buttonLabels['next']!['uz']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
