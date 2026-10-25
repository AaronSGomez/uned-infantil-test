import 'package:flutter/material.dart';

class AppTheme {
  // Colores relajantes de estudio (Azul petróleo y tonos neutros cálidos)
  static const Color primaryLight = Color(0xFF1E3A8A); // Deep Slate Navy
  static const Color secondaryLight = Color(0xFF0D9488); // Teal sereno
  static const Color backgroundLight = Color(0xFFF8FAFC); // Blanco roto suave
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textSubLight = Color(0xFF475569);

  static const Color primaryDark = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF2DD4BF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSubDark = Color(0xFF94A3B8);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
      background: backgroundLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMainLight, height: 1.3),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textMainLight),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textMainLight),
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: textMainLight, height: 1.5),
      bodyMedium: TextStyle(fontSize: 16, color: textSubLight, height: 1.4),
      labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      color: surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      background: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMainDark, height: 1.3),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textMainDark),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textMainDark),
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: textMainDark, height: 1.5),
      bodyMedium: TextStyle(fontSize: 16, color: textSubDark, height: 1.4),
      labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
