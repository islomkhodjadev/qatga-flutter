import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/theme_provider.dart';



class ThemeModeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.brightness_6),
      initialValue: themeProvider.themeMode,
      onSelected: (mode) {
        themeProvider.setTheme(mode);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Text('Light'),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Text('Dark'),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Text('System'),
        ),
      ],
    );
  }
}
