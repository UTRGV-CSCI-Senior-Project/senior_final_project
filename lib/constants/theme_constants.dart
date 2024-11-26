import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light Theme Colors
const Color lightBackgroundColor =Color(0xFFEEF2F5); // Light blue-gray background
const Color lightPrimaryColor = Color(0xFF2196F3); // Material Blue
const Color lightPrimaryFgColor = Colors.white; // White text on primary
const Color lightSecondaryColor = Color(0xFF64B5F6); // Lighter blue
const Color lightSecondaryFgColor = Colors.white; // White text on secondary
const Color lightAccentColor = Color(0xFF0D47A1); // Dark blue accent
const Color lightAccentFgColor = Colors.white; // White text on accent
const Color lightTextColor = Color(0xFF2C3E50); // Dark blue-gray text
const Color lightErrorColor = Color(0xFFD32F2F); // Bright red for errors in light theme
 Color lightErrorFgColor = Colors.red.withOpacity(0.1);

// Dark Theme Colors
const Color darkBackgroundColor = Color(0xFF1A1A2E); // Dark blue background
const Color darkPrimaryColor = Color(0xFF1E88E5); // Slightly muted blue
const Color darkPrimaryFgColor = Colors.white; // White text on primary
const Color darkSecondaryColor = Color(0xFF42A5F5); // Brighter blue
const Color darkSecondaryFgColor = Colors.white; // White text on secondary
const Color darkAccentColor = Color(0xFF90CAF9); // Light blue accent
const Color darkAccentFgColor = Color(0xFF1A1A2E); // Dark background color as text
const Color darkTextColor = Color(0xFFE1E8F0);
const Color darkErrorColor = Color(0xFFEF5350); // Vibrant red for errors in dark theme
 Color darkErrorFgColor = Colors.red.withOpacity(0.1);

ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: lightPrimaryColor),
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: lightPrimaryColor,
        foregroundColor: lightPrimaryFgColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: lightPrimaryFgColor,
          textStyle:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      filled: false,
      focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: lightPrimaryColor, width: 2),),
enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: lightTextColor, width: 2)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: lightTextColor, width: 2),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: lightBackgroundColor,
      elevation: 0,
      indicatorColor: lightBackgroundColor,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide
      
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: lightTextColor),
      displayMedium: TextStyle(color: lightTextColor),
      displaySmall: TextStyle(color: lightTextColor),
      headlineLarge: TextStyle(color: lightTextColor),
      headlineMedium: TextStyle(color: lightTextColor),
      headlineSmall: TextStyle(color: lightTextColor),
      titleLarge: TextStyle(color: lightTextColor),
      titleMedium: TextStyle(color: lightTextColor),
      titleSmall: TextStyle(color: lightTextColor),
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
      bodySmall: TextStyle(color: lightTextColor),
      labelLarge: TextStyle(color: lightTextColor),
      labelMedium: TextStyle(color: lightTextColor),
      labelSmall: TextStyle(color: lightTextColor),
    ),
    colorScheme:  ColorScheme.light(
      surface: lightBackgroundColor,
        primary: lightPrimaryColor,
        onPrimary: lightPrimaryFgColor,
        secondary: lightSecondaryColor,
        onSecondary: lightSecondaryFgColor,
        tertiary: lightAccentColor,
        onTertiary: lightAccentFgColor,
        error: lightErrorColor,
        onError: lightErrorFgColor

        ));

ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: darkPrimaryColor),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkPrimaryFgColor,
                padding: const EdgeInsets.symmetric(vertical: 12),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkPrimaryFgColor,
          textStyle:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: darkTextColor),
      filled: false,
      focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: darkPrimaryColor, width: 2),),
enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: darkTextColor, width: 2)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: darkTextColor, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      height: 30,
      indicatorColor: darkBackgroundColor,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide
    ),
    colorScheme:  ColorScheme.dark(
      surface: darkBackgroundColor,
        primary: darkPrimaryColor,
        onPrimary: darkPrimaryFgColor,
        secondary: darkSecondaryColor,
        onSecondary: darkSecondaryFgColor,
        tertiary: darkAccentColor,
        onTertiary: darkAccentFgColor,
        error: darkErrorColor,
        onError: darkErrorFgColor
        ));
