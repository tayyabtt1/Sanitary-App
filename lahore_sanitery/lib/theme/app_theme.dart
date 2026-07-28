import 'package:flutter/material.dart';

/// Explicit light/dark themes.
///
/// NOTE: with `useMaterial3: true`, if you only set `primarySwatch`
/// Flutter derives a full ColorScheme from a default seed that adds a
/// purple/pink surface tint to Scaffold backgrounds — that's what was
/// causing the pink tint. Defining ColorScheme.fromSeed() explicitly
/// with scaffoldBackgroundColor set directly avoids that.
class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    cardColor: Colors.white,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: Colors.grey.shade800,
  );
}