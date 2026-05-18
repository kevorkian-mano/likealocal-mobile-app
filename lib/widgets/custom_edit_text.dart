import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// CustomEditText - A flexible text input component that supports various input types,
/// optional prefix icons, customizable styling, and validation.
///
/// @param hintText - Placeholder text displayed in the input field
/// @param prefixIconPath - Optional path to SVG icon displayed on the left
/// @param backgroundColor - Background fill color of the input field
/// @param hasBorder - Whether to show a border around the input
/// @param isMultiline - Whether the input supports multiple lines
/// @param isTimeInput - Whether this is a time/date input with picker
/// @param controller - TextEditingController for managing input value
/// @param validator - Validation function for form validation
/// @param onTap - Callback function when the field is tapped
/// @param keyboardType - Type of keyboard to display
/// @param maxLines - Maximum number of lines for multiline input
class CustomEditText extends StatelessWidget {
  const CustomEditText({
    super.key,
    this.hintText,
    this.prefixIconPath,
    this.backgroundColor,
    this.hasBorder = false,
    this.isMultiline = false,
    this.isTimeInput = false,
    this.controller,
    this.validator,
    this.onTap,
    this.keyboardType,
    this.maxLines,
  });

  /// Placeholder text displayed in the input field
  final String? hintText;

  /// Optional path to SVG icon displayed on the left
  final String? prefixIconPath;

  /// Background fill color of the input field
  final Color? backgroundColor;

  /// Whether to show a border around the input
  final bool hasBorder;

  /// Whether the input supports multiple lines
  final bool isMultiline;

  /// Whether this is a time/date input with picker
  final bool isTimeInput;

  /// TextEditingController for managing input value
  final TextEditingController? controller;

  /// Validation function for form validation
  final String? Function(String?)? validator;

  /// Callback function when the field is tapped
  final VoidCallback? onTap;

  /// Type of keyboard to display
  final TextInputType? keyboardType;

  /// Maximum number of lines for multiline input
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onTap: isTimeInput ? _handleTimeInput : onTap,
        readOnly: isTimeInput,
        keyboardType:
            keyboardType ??
            (isMultiline ? TextInputType.multiline : TextInputType.text),
        maxLines: _getMaxLines(),
        style: TextStyleHelper.instance.title16RegularInter.copyWith(
          color: const Color(0xFF191C1A),
          height: isMultiline ? 1.5 : 1.25,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyleHelper.instance.title16RegularInter.copyWith(
            color: appTheme.gray_400,
            height: isMultiline ? 1.5 : 1.25,
          ),
          prefixIcon: prefixIconPath != null ? _buildPrefixIcon() : null,
          filled: true,
          fillColor: backgroundColor ?? Color(0xFFF1F5F2),
          contentPadding: _getContentPadding(),
          border: _getBorder(),
          enabledBorder: _getBorder(),
          focusedBorder: _getBorder(),
          errorBorder: _getErrorBorder(),
          focusedErrorBorder: _getErrorBorder(),
        ),
      ),
    );
  }

  Widget _buildPrefixIcon() {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: CustomImageView(
        imagePath: prefixIconPath!,
        height: 20.h,
        width: 16.h,
      ),
    );
  }

  EdgeInsets _getContentPadding() {
    if (prefixIconPath != null) {
      return EdgeInsets.fromLTRB(30.h, 16.h, 8.h, 16.h);
    }
    if (isMultiline) {
      return EdgeInsets.fromLTRB(16.h, 18.h, 16.h, 14.h);
    }
    return EdgeInsets.fromLTRB(16.h, 18.h, 16.h, 18.h);
  }

  int? _getMaxLines() {
    if (isMultiline) return null;
    return maxLines ?? 1;
  }

  OutlineInputBorder _getBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.h),
      borderSide: hasBorder
          ? BorderSide(color: appTheme.black_900_0c, width: 1.h)
          : BorderSide.none,
    );
  }

  OutlineInputBorder _getErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.h),
      borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
    );
  }

  void _handleTimeInput() {
    if (onTap != null) {
      onTap!();
    }
  }
}
