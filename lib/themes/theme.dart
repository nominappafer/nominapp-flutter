import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Colores principales basados en el logo
  static const Color primaryBrown = Color(0xFF6B2C1C); // Marrón chocolate
  static const Color secondaryGold = Color(0xFFD4A373); // Dorado trigo
  static const Color backgroundCream = Color(0xFFFFF8F0); // Crema cálido
  static const Color accentTerracotta = Color(0xFFE76F51); // Acento cálido
  static const Color textDark = Color(0xFF2C2C2C); // Texto principal
  static const Color textLightBrown = Color(0xFF7A5C58); // Texto secundario

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // si quieres el estilo más moderno de Flutter

      primaryColor: primaryBrown,
      scaffoldBackgroundColor: backgroundCream,

      // 🔹 Esquema de colores completo
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrown,
        primary: primaryBrown,
        secondary: secondaryGold,
        error: accentTerracotta,
        background: backgroundCream,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),

      // 🔹 Tipografía
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: textLightBrown,
        ),
      ),

      // 🔹 AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // 🔹 Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrown,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      // 🔹 Cards
      cardTheme: CardThemeData(
        color: backgroundCream,
        elevation: 3,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 🔹 Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBrown, width: 2),
        ),
      ),
    );
  }
}
