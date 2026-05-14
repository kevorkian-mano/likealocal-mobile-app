import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// A customizable button component that supports various styling options
/// including background colors, text styling, borders, shadows, and spacing.
///
/// @param text - The text to display on the button
/// @param onPressed - Callback function when button is pressed
/// @param backgroundColor - Background color of the button
/// @param textColor - Color of the button text
/// @param borderRadius - Border radius for rounded corners
/// @param fontFamily - Font family for the text
/// @param fontSize - Font size for the text
/// @param fontWeight - Font weight for the text
/// @param padding - Internal padding of the button
/// @param margin - External margin around the button
/// @param boxShadow - Shadow effect for the button
/// @param width - Width of the button
/// @param height - Height of the button
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.boxShadow,
    this.width,
    this.height,
  });

  /// The text to display on the button
  final String text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color of the button text
  final Color? textColor;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Font family for the text
  final String? fontFamily;

  /// Font size for the text
  final double? fontSize;

  /// Font weight for the text
  final FontWeight? fontWeight;

  /// Internal padding of the button
  final EdgeInsets? padding;

  /// External margin around the button
  final EdgeInsets? margin;

  /// Shadow effect for the button
  final List<BoxShadow>? boxShadow;

  /// Width of the button
  final double? width;

  /// Height of the button
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.only(top: 44.h),
      decoration: BoxDecoration(boxShadow: boxShadow),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF1B3022),
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 18.h, horizontal: 30.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 32.h),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyleHelper.instance.textStyle17.copyWith(
            color: textColor ?? appTheme.whiteCustom,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
