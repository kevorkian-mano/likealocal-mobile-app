import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get gray_900 => Color(0xFF191C1A);
  Color get gray_50 => Color(0xFFFBFDFB);
  Color get gray_900_01 => Color(0xFF1B3022);
  Color get gray_800 => Color(0xFF444945);
  Color get gray_400 => Color(0xFFC4C9C5);
  Color get gray_100 => Color(0xFFF1F5F2);
  Color get gray_800_01 => Color(0xFF2D4B36);
  Color get gray_600 => Color(0xFF6B7280);
  Color get blue_gray_700 => Color(0xFF4A5D4E);
  Color get black_900_0c => Color(0x0C000000);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get gray_200_4c => Color(0x4CEDF0ED);
  Color get gray_400_4c => Color(0x4CC2C8C1);
  Color get gray_300 => Color(0xFFDEE5DD);
  Color get gray_700 => Color(0xFF695D56);
  Color get green_700 => Color(0xFF3C8D46);
  Color get gray_400_33 => Color(0x33BEAFA7);
  Color get gray_50_e5 => Color(0xE5FFF8F5);
  Color get gray_300_01 => Color(0xFFDDE6DD);
  Color get gray_50_01 => Color(0xFFF7F9F7);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get redCustom => Colors.red;
  Color get greyCustom => Colors.grey;
  Color get color66661B => Color(0x66661B30);
  Color get colorBF1B30 => Color(0xBF1B3022);
  Color get colorCCFFFF => Color(0xCCFFFFFF);
  Color get colorB2FFFF => Color(0xB2FFFFFF);
  Color get colorCCFBFD => Color(0xCCFBFDFB);
  Color get color220F1B => Color(0x220F1B30);
  Color get colorC54CC4 => Color(0xC54CC4C9);
  Color get colorC1C2C8 => Color(0xC1C2C8C1);
  Color get color223F1B => Color(0x223F1B30);
  Color get colorEDF0ED => Color(0xFFEDF0ED);
  Color get colorFFE5FF => Color(0xFFE5FFF8);
  Color get colorFF33BE => Color(0xFF33BEAF);
  Color get colorFF8888 => Color(0xFF888888);
  Color get colorFF0000 => Color(0xFF000000);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
