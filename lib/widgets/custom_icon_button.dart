import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * A customizable icon button widget that supports different icons, colors, and sizes.
 * 
 * This widget provides a circular icon button with customizable background color,
 * icon, size, and padding. It uses Flutter's default IconButton for proper
 * accessibility and interaction handling.
 * 
 * @param iconPath - Path to the icon image (SVG, PNG, or network URL)
 * @param onPressed - Callback function triggered when button is pressed
 * @param backgroundColor - Background color of the button
 * @param size - Size of the button (both width and height)
 * @param padding - Padding around the icon
 * @param iconColor - Color tint for the icon (optional)
 */
class CustomIconButton extends StatelessWidget {
  CustomIconButton({
    Key? key,
    required this.iconPath,
    this.onPressed,
    this.backgroundColor,
    this.size,
    this.padding,
    this.iconColor,
  }) : super(key: key);

  /// Path to the icon image (SVG, PNG, or network URL)
  final String iconPath;

  /// Callback function triggered when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Size of the button (both width and height)
  final double? size;

  /// Padding around the icon
  final EdgeInsets? padding;

  /// Color tint for the icon
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 40.0;
    final buttonPadding = padding ?? EdgeInsets.all(10.0);
    final buttonBackgroundColor = backgroundColor ?? Color(0xFF1B3022);

    return SizedBox(
      height: buttonSize.h,
      width: buttonSize.h,
      child: IconButton(
        onPressed: onPressed,
        icon: CustomImageView(
          imagePath: iconPath,
          height: (buttonSize - (buttonPadding.horizontal)).h,
          width: (buttonSize - (buttonPadding.horizontal)).h,
          color: iconColor,
          fit: BoxFit.contain,
        ),
        style: IconButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          padding: EdgeInsets.all(buttonPadding.top.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.h),
          ),
        ),
      ),
    );
  }
}
