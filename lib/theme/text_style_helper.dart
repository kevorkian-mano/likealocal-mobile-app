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

  TextStyle get display48BoldPlusJakartaSans => TextStyle(
    fontSize: 48.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Plus Jakarta Sans',
    color: appTheme.whiteCustom,
  );

  TextStyle get display36ExtraBoldPlusJakartaSans => TextStyle(
    fontSize: 36.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Plus Jakarta Sans',
    color: appTheme.gray_900,
  );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline30ExtraBoldPlusJakartaSans => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Plus Jakarta Sans',
    color: appTheme.whiteCustom,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20ExtraBoldPlusJakartaSans => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w800,
    fontFamily: 'Plus Jakarta Sans',
    color: appTheme.gray_900,
  );

  TextStyle get title20BoldPlusJakartaSans => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Plus Jakarta Sans',
    color: appTheme.gray_900,
  );

  TextStyle get title18RegularInter => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: appTheme.colorCCFFFF,
  );

  TextStyle get title18SemiBold => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w600,
    color: appTheme.gray_900,
  );

  TextStyle get title16RegularInter => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14 =>
      TextStyle(fontSize: 14.fSize, color: appTheme.gray_900);

  TextStyle get body14MediumInter => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: appTheme.colorB2FFFF,
  );

  TextStyle get body14BoldInter => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: appTheme.gray_900,
  );

  TextStyle get body12SemiBoldInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: appTheme.gray_800,
  );

  TextStyle get body12BoldInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: appTheme.gray_800,
  );

  TextStyle get body12MediumInter => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: appTheme.gray_800,
  );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label10BoldInter => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  TextStyle get label10MediumInter => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
  );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get textStyle17 => TextStyle();
}
