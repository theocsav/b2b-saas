import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    fontFamily: 'Inter',
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF0EA5E9),
      secondary: const Color(0xFF2563EB),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF1F2937), 
      error: Colors.redAccent,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
      bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white), // For buttons
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)), // For input labels
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0EA5E9), // Primary button color
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0EA5E9),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    cardTheme: CardTheme( 
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
