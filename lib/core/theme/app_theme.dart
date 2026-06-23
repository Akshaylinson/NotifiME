import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Modern Color Palette
  static const Color primaryBlue = Color(0xFF4C6EF5);
  static const Color primaryDark = Color(0xFF3B5BDB);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentTeal = Color(0xFF14B8A6);
  
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: accentPurple,
      tertiary: accentTeal,
      surface: surfaceLight,
      background: backgroundLight,
      error: const Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
      primaryContainer: primaryBlue,
      secondaryContainer: accentPurple.withOpacity(0.1),
    ),
    scaffoldBackgroundColor: backgroundLight,
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundLight,
      foregroundColor: textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardLight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
    ),
    
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
      space: 1,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentPurple,
      tertiary: accentTeal,
      surface: surfaceDark,
      background: backgroundDark,
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
      onBackground: textLight,
      primaryContainer: primaryBlue,
      secondaryContainer: accentPurple.withOpacity(0.2),
    ),
    scaffoldBackgroundColor: backgroundDark,
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundDark,
      foregroundColor: textLight,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textLight),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardDark,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    iconTheme: IconThemeData(
      color: textLight.withOpacity(0.7),
      size: 24,
    ),
    
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
      displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textLight),
      displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textLight),
      headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textLight),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textLight),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textLight),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textLight),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textLight.withOpacity(0.7)),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textLight.withOpacity(0.6)),
    ),
    
    dividerTheme: const DividerThemeData(
      color: Color(0xFF475569),
      thickness: 1,
      space: 1,
    ),
  );
}
