import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DatingApp theme configuration
/// Uses Coral (#FF7F50) as primary - warm but not cliché pink
class AppTheme {
  AppTheme._();
  
  // Brand Colors - Coral palette
  static const primaryColor = Color(0xFFFF7F50);  // Coral - main brand
  static const primaryLight = Color(0xFFFFB199);  // Lighter coral
  static const primaryDark = Color(0xFFE65100);   // Darker coral
  
  static const secondaryColor = Color(0xFF6C63FF); // Purple accent
  static const tertiaryColor = Color(0xFF1ABC9C);  // Teal
  
  // Neutral Colors
  static const backgroundColor = Color(0xFFF8F9FA);
  static const surfaceColor = Color(0xFFFFFFFF);
  static const dividerColor = Color(0xFFE5E7EB);
  
  // Semantic Colors
  static const successColor = Color(0xFF10B981);  // Green
  static const errorColor = Color(0xFFE63946);    // Red
  static const warningColor = Color(0xFFF59E0B);  // Amber
  static const infoColor = Color(0xFF3B82F6);     // Blue
  
  // Text Colors
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: textOnPrimary,
      onSurface: textPrimary,
    ),
    
    scaffoldBackgroundColor: backgroundColor,
    dividerColor: dividerColor,
    
    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    
    // Component Themes
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
