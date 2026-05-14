import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// Custom bottom navigation bar component that provides navigation between different screens
/// with customizable items, icons, labels and styling options
class CustomBottomBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomBottomBar({
    super.key,
    required this.bottomBarItemList,
    required this.onChanged,
    this.selectedIndex = 0,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.elevation,
  });

  /// List of bottom bar items with their properties
  final List<CustomBottomBarItem> bottomBarItemList;

  /// Current selected index of the bottom bar
  final int selectedIndex;

  /// Callback function triggered when a bottom bar item is tapped
  final Function(int) onChanged;

  /// Background color of the bottom bar
  final Color? backgroundColor;

  /// Color of the selected item
  final Color? selectedItemColor;

  /// Color of the unselected items
  final Color? unselectedItemColor;

  /// Text style for selected item labels
  final TextStyle? selectedLabelStyle;

  /// Text style for unselected item labels
  final TextStyle? unselectedLabelStyle;

  /// Elevation of the bottom bar
  final double? elevation;

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFFE5FFF8).withAlpha(245),
        border: Border(
          top: BorderSide(color: Color(0xFF33BEAF).withAlpha(166), width: 1.h),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF888888).withAlpha(128),
            blurRadius: 24.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: appTheme.transparentCustom,
        selectedItemColor: selectedItemColor ?? Color(0xFF3C8D46),
        unselectedItemColor: unselectedItemColor ?? Color(0xFF695D56),
        selectedLabelStyle:
            selectedLabelStyle ?? TextStyleHelper.instance.label10BoldInter,
        unselectedLabelStyle:
            unselectedLabelStyle ?? TextStyleHelper.instance.label10MediumInter,
        elevation: elevation ?? 0,
        items: bottomBarItemList.map((item) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Icon(
                item.icon,
                color: unselectedItemColor ?? Color(0xFF695D56),
                size: 24.h,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Icon(
                item.activeIcon ?? item.icon,
                color: selectedItemColor ?? Color(0xFF3C8D46),
                size: 24.h,
              ),
            ),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }
}

/// Item data model for custom bottom bar
class CustomBottomBarItem {
  CustomBottomBarItem({
    required this.icon,
    required this.title,
    required this.routeName,
    this.activeIcon,
  });

  /// The icon data
  final IconData icon;

  /// The active icon data (optional)
  final IconData? activeIcon;

  /// Title text shown below the icon
  final String title;

  /// Route name for navigation
  final String routeName;
}
