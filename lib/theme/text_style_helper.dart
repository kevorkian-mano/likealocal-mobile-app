import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Display Styles
  // Large text styles typically used for headers and hero elements

  TextStyle get display48BoldOutfit => TextStyle(
    fontSize: 48.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Outfit',
    color: Colors.white, // Usually over image
  );

  TextStyle get display36ExtraBoldOutfit => TextStyle(
    fontSize: 36.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Outfit',
    color: Colors.white, // Usually over image
  );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline30ExtraBoldOutfit => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Outfit',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get title24ExtraBoldOutfit => TextStyle(
    fontSize: 24.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Outfit',
    color: theme.colorScheme.onSurface,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularInter => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.8),
  );

  TextStyle get title20ExtraBoldOutfit => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Outfit',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get title20BoldOutfit => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Outfit',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get title18RegularInter => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.8),
  );

  TextStyle get title18SemiBoldInter => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get title16RegularInter => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14Inter => TextStyle(
    fontSize: 14.fSize,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get body14MediumInter => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.7),
  );

  TextStyle get body14BoldInter => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get body12SemiBoldInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.9),
  );

  TextStyle get body12BoldInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get body12MediumInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.8),
  );

  TextStyle get body12RegularInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get textStyle17 => TextStyle(
    fontSize: 17.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface,
  );

  TextStyle get body16MediumInter => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.8),
  );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label10BoldInter => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: appTheme.sunlightGold,
  );

  TextStyle get label10MediumInter => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: theme.colorScheme.onSurface.withOpacity(0.6),
  );

  // Legacy Support for generated screens
  TextStyle get title20ExtraBoldPlusJakartaSans => title20ExtraBoldOutfit;
  TextStyle get display36ExtraBoldPlusJakartaSans => display36ExtraBoldOutfit;
  TextStyle get title20BoldPlusJakartaSans => title20BoldOutfit;
  TextStyle get title18SemiBold => title18SemiBoldInter;
  TextStyle get body14 => body14Inter;
  TextStyle get title20RegularRoboto => title20RegularInter;
}
