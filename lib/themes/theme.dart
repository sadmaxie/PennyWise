import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1BBC9B), // Button color
    background: Color(0xFF252D35), // Background
    surface: Color(0xFF2D3E50), // Slightly lighter background for cards
    onPrimary: Colors.white, // Text on buttons
    onBackground: Colors.white, // Default text color
    onSurface: Colors.white, // Text on surfaces
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1BBC9B), // Button color
    background: Color(0xFF252D35), // Background
    surface: Color(0xFF2D3E50), // Slightly lighter background for cards
    onPrimary: Colors.white, // Text on buttons
    onBackground: Colors.white, // Default text color
    onSurface: Colors.white, // Text on surfaces
  ),
);