import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLightMode() {
    _isDarkMode = false;
    notifyListeners();
  }

  void setDarkMode() {
    _isDarkMode = true;
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: const Color(0xFFE57F84),
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFDF8F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE57F84),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 8,
        shadowColor: const Color(0xFFE57F84).withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE57F84),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFF4E4A47)),
        headlineMedium: TextStyle(color: Color(0xFF4E4A47)),
        headlineSmall: TextStyle(color: Color(0xFF4E4A47)),
        bodyLarge: TextStyle(color: Color(0xFF4E4A47)),
        bodyMedium: TextStyle(color: Color(0xFF4E4A47)),
        bodySmall: TextStyle(color: Color(0xFF8B7D7D)),
        titleLarge: TextStyle(color: Color(0xFF2D2D2D)),
        titleMedium: TextStyle(color: Color(0xFF2D2D2D)),
        titleSmall: TextStyle(color: Color(0xFF2D2D2D)),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFE57F84),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE57F84), width: 2),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE57F84),
        secondary: Color(0xFFF8E8E9),
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF4E4A47),
        onSurface: Color(0xFF4E4A47),
        onError: Colors.white,
        brightness: Brightness.light,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: const Color(0xFFE57F84),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2D2D2D),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE57F84),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFE57F84),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3D3D3D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE57F84), width: 2),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE57F84),
        secondary: Color(0xFF3D3D3D),
        surface: Color(0xFF2D2D2D),
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  Color get primaryColor => const Color(0xFFE57F84);
  
  Color get backgroundColor => _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFDF8F5);
  
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF4E4A47);
  
  Color get secondaryTextColor => _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF8B7D7D);
  
  Color get surfaceColor => _isDarkMode ? const Color(0xFF3D3D3D) : Colors.white.withValues(alpha: 0.9);

  List<Color> get backgroundGradient => _isDarkMode 
      ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
      : [const Color(0xFFFDF8F5), const Color(0xFFF8E8E9)];

  List<Color> get cardGradient => _isDarkMode
      ? [const Color(0xFF2D2D2D), const Color(0xFF3D3D3D)]
      : [Colors.white, const Color(0xFFFDF8F5).withValues(alpha: 0.8)];
} 
