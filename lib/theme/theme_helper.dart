import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.
class ThemeHelper {
  // The current app theme
  final _appTheme = "midnightPine";

  // A map of custom color themes supported by the app
  final Map<String, LightCodeColors> _supportedCustomColor = {
    'midnightPine': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'midnightPine': ColorSchemes.midnightPineColorScheme,
  };

  /// Returns the current theme colors.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ??
        ColorSchemes.midnightPineColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          visualDensity: VisualDensity.standard,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 32,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  /// Returns the colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final midnightPineColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3E5641), // Deep Forest
    onPrimary: Colors.white,
    secondary: Color(0xFFBDB76B), // Sunlight Gold (Accent)
    onSecondary: Color(0xFF0B1E19),
    error: Color(0xFFCF6679),
    onError: Colors.black,
    surface: Color(0xFFF5F5DC), // Pale Sand (Background)
    onSurface: Color(0xFF0B1E19), // Midnight Pine (Text)
  );
}

class LightCodeColors {
  // Brand Colors
  Color get midnightPine => Color(0xFF0B1E19);
  Color get deepForest => Color(0xFF3E5641);
  Color get charcoal => Color(0xFF202124);
  Color get paleSand => Color(0xFFF5F5DC);
  Color get sunlightGold => Color(0xFFBDB76B);

  // App Colors
  Color get gray_900 => Color(0xFF191C1A);
  Color get gray_50 => Color(0xFFFBFDFB);
  Color get white_A700 => Color(0xFFFFFFFF);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get greyCustom => Colors.grey;

  // Legacy Support for generated screens
  Color get grey100 => const Color(0xFFF5F5F5);
  Color get grey200 => const Color(0xFFEEEEEE);
  Color get gray_100 => const Color(0xFFF5F5F5);
  Color get gray_300 => const Color(0xFFE0E0E0);
  Color get gray_400 => const Color(0xFFBDBDBD);
  Color get gray_800_01 => const Color(0xFF424242);
  Color get gray_900_01 => const Color(0xFF212121);
  Color get colorCCFBFD => const Color(0xFFCCFBFD);
  Color get color220F1B => const Color(0xFF220F1B);
  Color get color223F1B => const Color(0xFF223F1B);
  Color get colorC54CC4 => const Color(0xFFC54CC4);
  Color get colorEDF0ED => const Color(0xFFEDF0ED);
  Color get colorC1C2C8 => const Color(0xFFC1C2C8);
  Color get colorFF0000 => const Color(0xFFFF0000);
  Color get redCustom => const Color(0xFFFF0000);
  Color get black_900_0c => const Color(0x0C000000);
}
