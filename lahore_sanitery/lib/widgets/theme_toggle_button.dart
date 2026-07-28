import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';

/// Drop this into any AppBar's actions list. Shows a sun/moon icon
/// depending on current mode and flips the global theme on tap.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: toggleTheme,
        );
      },
    );
  }
}