import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * A customizable dropdown widget that provides a styled dropdown button form field
 * with configurable appearance, validation, and behavior options.
 * 
 * @param items - List of dropdown items to display
 * @param placeholder - Placeholder text shown when no item is selected
 * @param value - Currently selected value
 * @param onChanged - Callback function when selection changes
 * @param validator - Optional validation function for form validation
 * @param backgroundColor - Background color of the dropdown
 * @param textColor - Color of the text and placeholder
 * @param borderRadius - Border radius for rounded corners
 * @param rightIcon - Path to the dropdown arrow icon
 * @param iconSize - Size of the dropdown icon
 * @param padding - Internal padding of the dropdown
 * @param margin - External margin around the dropdown
 * @param fontSize - Font size of the text
 * @param fontWeight - Font weight of the text
 * @param fontFamily - Font family for the text
 * @param isEnabled - Whether the dropdown is enabled or disabled
 */
class CustomDropdown extends StatelessWidget {
  CustomDropdown({
    Key? key,
    this.items,
    this.placeholder,
    this.value,
    this.onChanged,
    this.validator,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.rightIcon,
    this.iconSize,
    this.padding,
    this.margin,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.isEnabled,
  }) : super(key: key);

  final List<DropdownMenuItem<String>>? items;
  final String? placeholder;
  final String? value;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final String? rightIcon;
  final double? iconSize;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final bool? isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: 4.h),
      child: DropdownButtonFormField<String>(
        items: items ?? [],
        initialValue: value,
        onChanged: (isEnabled ?? true) ? onChanged : null,
        validator: validator,
        decoration: InputDecoration(
          hintText: placeholder ?? "Select an option",
          hintStyle: TextStyleHelper.instance.textStyle17.copyWith(
            color: textColor ?? Color(0xFF191C1A),
          ),
          filled: true,
          fillColor: backgroundColor ?? Color(0xFFF1F5F2),
          contentPadding:
              padding ?? EdgeInsets.fromLTRB(14.h, 16.h, 38.h, 16.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
          ),
        ),
        style: TextStyleHelper.instance.textStyle17.copyWith(
          color: textColor ?? Color(0xFF191C1A),
        ),
        icon: CustomImageView(
          imagePath: rightIcon ?? ImageConstant.imgArrowdown,
          height: iconSize ?? 20.h,
          width: iconSize ?? 24.h,
        ),
        iconSize: 0,
        isExpanded: true,
        dropdownColor: backgroundColor ?? Color(0xFFF1F5F2),
      ),
    );
  }
}
