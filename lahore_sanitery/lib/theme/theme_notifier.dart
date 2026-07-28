import 'package:flutter/material.dart';

/// Global theme mode state. Any widget can read/toggle this without
/// needing a state management package — fine for a single app-wide
/// setting like this. Wrapped in main.dart with a ValueListenableBuilder
/// that rebuilds MaterialApp whenever this changes.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void toggleTheme() {
  themeNotifier.value =
      themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}