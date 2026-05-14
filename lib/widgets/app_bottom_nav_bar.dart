import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../core/providers/user_provider.dart';
import '../presentation/share_hidden_gem_screen/share_hidden_gem_initial_page.dart';
import 'custom_bottom_bar.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return CustomBottomBar(
      selectedIndex: selectedIndex,
      onChanged: (index) => _onItemTapped(context, index),
      bottomBarItemList: [
        CustomBottomBarItem(
          icon: Icons.explore_outlined,
          title: 'Explore',
          routeName: AppRoutes.explorePageWithNotifScreen,
        ),
        CustomBottomBarItem(
          icon: Icons.map_outlined,
          title: 'Map',
          routeName: AppRoutes.mapsPage,
        ),
        CustomBottomBarItem(
          icon: Icons.add_circle_outline,
          title: 'Add',
          routeName: AppRoutes.shareHiddenGemScreen,
        ),
        CustomBottomBarItem(
          icon: Icons.chat_bubble_outline,
          title: 'Guide',
          routeName: AppRoutes.chatListScreen,
        ),
        CustomBottomBarItem(
          icon: Icons.person_outline,
          title: 'Profile',
          routeName: AppRoutes.userProfilePage,
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // Already on this screen

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAuthenticated = userProvider.isAuthenticated;

    // Restricted routes for guests
    if (!isAuthenticated && (index == 2 || index == 3 || index == 4)) {
      _showGuestSignUpPrompt(context);
      return;
    }

    String targetRoute;
    switch (index) {
      case 0:
        targetRoute = AppRoutes.explorePageWithNotifScreen;
        break;
      case 1:
        targetRoute = AppRoutes.mapsPage;
        break;
      case 2:
        _showShareHiddenGemModal(context);
        return;
      case 3:
        targetRoute = AppRoutes.chatListScreen;
        break;
      case 4:
        targetRoute = AppRoutes.userProfilePage;
        break;
      default:
        targetRoute = AppRoutes.explorePageWithNotifScreen;
    }

    // Use pushReplacementNamed to prevent stacking the navigation backstack
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  void _showGuestSignUpPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Color(0xFF1B3022)),
            SizedBox(height: 16),
            Text(
              'Sign Up Required',
              style: TextStyleHelper.instance.title20BoldOutfit,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'You need an account to add places, view guides, or access your profile. Join our community of local explorers today!',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B3022),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  Navigator.pushNamed(context, AppRoutes.signUpPage);
                },
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close modal
                Navigator.pushNamed(context, AppRoutes.signInPage);
              },
              child: Text(
                'Already have an account? Log In',
                style: TextStyle(
                  color: Color(0xFF1B3022),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareHiddenGemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: ShareHiddenGemInitialPage.builder(context),
        );
      },
    );
  }
}
