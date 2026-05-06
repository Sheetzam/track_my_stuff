import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The breathtaking, ultra-premium design system for TrackMyStuff.
/// Uses a deep space dark mode with vibrant neon accents and modern typography.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),     // Vibrant Neon Purple
        surface: Color(0xFF1E1E2C),  // Deep space background
      ),
      // Utilizing modern, clean sans-serif geometry
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF12121D),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E2C),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
