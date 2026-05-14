import 'package:flutter/material.dart';
import '../../core/utils/database_seeder.dart';

import '../../core/app_export.dart';
import './provider/app_navigation_provider.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({super.key});

  @override
  AppNavigationScreenState createState() => AppNavigationScreenState();
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppNavigationProvider(),
      child: AppNavigationScreen(),
    );
  }
}

class AppNavigationScreenState extends State<AppNavigationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      _buildScreenTitle(
                        context,
                        screenTitle: "Landing Page",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.onboardingScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Add New Place Page",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.shareHiddenGemScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Admin Intelligence Dashboard",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.adminDashboard),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Super User Impact Dashboard",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.superUserDashboard,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Social Chat Hub",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.chatListScreen),
                      ),
                      const SizedBox(height: 20),
                      _buildScreenTitle(
                        context,
                        screenTitle: "⚠️ WIPE AND SEED DATABASE ⚠️",
                        onTapScreenTitle: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seeding database... Please wait.'),
                            ),
                          );
                          try {
                            await DatabaseSeeder.seed();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Database seeded successfully!',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
    BuildContext context, {
    required String screenTitle,
    Function? onTapScreenTitle,
  }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        decoration: BoxDecoration(color: Color(0XFFFFFFFF)),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  screenTitle,
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.title20RegularRoboto.copyWith(
                    color: Color(0XFF000000),
                  ),
                ),
                Icon(Icons.arrow_forward, color: Color(0XFF343330)),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1.h, thickness: 1.h, color: Color(0XFFD2D2D2)),
          ],
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(BuildContext context, String routeName) {
    NavigatorService.pushNamed(routeName);
  }

  /// Common click event for bottomsheet
  void onTapBottomSheetTitle(BuildContext context, Widget className) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return className;
      },
      isScrollControlled: true,
      backgroundColor: appTheme.transparentCustom,
    );
  }

  /// Common click event for dialog
  void onTapDialogTitle(BuildContext context, Widget className) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: className,
          backgroundColor: appTheme.transparentCustom,
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
