import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Design Tokens
  static const Color obsidianDeep = Color(0xFF020617);
  static const Color obsidianLight = Color(0xFF0F172A);
  static const Color royalIndigo = Color(0xFF6366F1);
  static const Color slateIndigo = Color(0xFF818CF8);
  static const Color slateText = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalIndigo,
        brightness: Brightness.dark,
        surface: obsidianLight,
        onSurface: Colors.white,
        primary: royalIndigo,
        onPrimary: Colors.white,
        secondary: slateIndigo,
        onSecondary: Colors.white,
        background: obsidianDeep,
      ),
      scaffoldBackgroundColor: obsidianDeep,
      appBarTheme: AppBarTheme(
        backgroundColor: obsidianDeep.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
            fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: Colors.white),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: slateText),
        labelLarge: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: obsidianLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: royalIndigo,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalIndigo,
          foregroundColor: Colors.white,
          textStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: obsidianLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: royalIndigo, width: 2),
        ),
        labelStyle: const TextStyle(color: slateText),
        hintStyle: const TextStyle(color: Colors.white30),
      ),
    );
  }
}
