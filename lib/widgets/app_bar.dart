import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:boyshub/widgets/theme_swticher.dart';


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // <-- add this

  MyAppBar({required this.title, this.actions}); // <-- update constructor

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return AppBar(
      title: Text(title),
      actions: [
        ThemeModeSwitcher(),

        // Add your custom actions first
        if (actions != null) ...actions!,
        // Always show the language switcher as the last action
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (lang) {
            context.read<LanguageProvider>().setLang(lang);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'uz', child: Text('Uzbekcha')),
            const PopupMenuItem(value: 'ru', child: Text('Русский')),
            const PopupMenuItem(value: 'en', child: Text('English')),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
