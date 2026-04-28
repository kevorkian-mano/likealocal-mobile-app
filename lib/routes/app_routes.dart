import 'package:flutter/material.dart';
import '../presentation/map_view_page/map_view_page.dart';
import '../presentation/maps_page/maps_page.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/share_hidden_gem_screen/share_hidden_gem_screen.dart';
import '../presentation/place_details_screen/place_details_screen.dart';
import '../presentation/explore_page_with_notif_screen/explore_page_with_notif_screen.dart';
import '../presentation/chat_with_post_owner_page/chat_with_post_owner_page.dart';
import '../presentation/user_profile_page/user_profile_page.dart';
import '../presentation/settings_page/settings_page.dart';
import '../presentation/sign_in_page/sign_in_page.dart';
import '../presentation/sign_up_page/sign_up_page.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String onboardingScreen = '/onboarding_screen';
  static const String shareHiddenGemScreen = '/share_hidden_gem_screen';
  static const String shareHiddenGemScreenInitialPage =
      '/share_hidden_gem_screen_initial_page';
  static const String placeDetailsScreen = '/place_details_screen';
  static const String mapsPage = '/maps_page';
  static const String mapViewPage = '/map_view_page';
  static const String explorePageWithNotifScreen = '/explore_page_with_notif_screen';
  static const String chatWithPostOwnerPage = '/chat_with_post_owner_page';
  static const String userProfilePage = '/user_profile_page';
  static const String settingsPage = '/settings_page';
  static const String signInPage = '/sign_in_page';
  static const String signUpPage = '/sign_up_page';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    onboardingScreen: OnboardingScreen.builder,
    shareHiddenGemScreen: ShareHiddenGemScreen.builder,
    placeDetailsScreen: PlaceDetailsScreen.builder,
    mapsPage: MapsPage.builder,
    mapViewPage: MapViewPage.builder,
    explorePageWithNotifScreen: ExplorePageWithNotifScreen.builder,
    chatWithPostOwnerPage: ChatWithPostOwnerPage.builder,
    userProfilePage: (context) => const UserProfilePage(),
    settingsPage: SettingsPage.builder,
    signInPage: (context) => const SignInPage(),
    signUpPage: (context) => const SignUpPage(),
    appNavigationScreen: AppNavigationScreen.builder,
    initialRoute: OnboardingScreen.builder,
  };
}
