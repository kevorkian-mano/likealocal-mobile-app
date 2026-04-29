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
import '../presentation/vibe_picker_screen/vibe_picker_screen.dart';
import '../presentation/pricing_page/pricing_page.dart';
import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/admin_moderation_queue_screen/admin_moderation_queue_screen.dart';
import '../presentation/super_user_dashboard_screen/super_user_dashboard_screen.dart';
import '../presentation/chat_list_screen/chat_list_screen.dart';
import '../presentation/chat_details_screen/chat_details_screen.dart';
import '../presentation/preference_summary_screen/preference_summary_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../core/auth_wrapper.dart';

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
  static const String vibePickerScreen = '/vibe_picker_screen';
  static const String preferenceSummaryScreen = '/preference_summary_screen';
  static const String pricingPage = '/pricing_page';
  static const String adminDashboard = '/admin_dashboard';
  static const String adminModerationQueue = '/admin_moderation_queue';
  static const String superUserDashboard = '/super_user_dashboard';
  static const String chatListScreen = '/chat_list_screen';
  static const String chatDetailsScreen = '/chat_details_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    onboardingScreen: OnboardingScreen.builder,
    vibePickerScreen: (context) => const VibePickerScreen(),
    preferenceSummaryScreen: PreferenceSummaryScreen.builder,
    pricingPage: PricingPage.builder,
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
    adminDashboard: AdminDashboardScreen.builder,
    adminModerationQueue: AdminModerationQueueScreen.builder,
    superUserDashboard: SuperUserDashboardScreen.builder,
    chatListScreen: ChatListScreen.builder,
    chatDetailsScreen: ChatDetailsScreen.builder,
    appNavigationScreen: AppNavigationScreen.builder,
    initialRoute: (context) => const AuthWrapper(),
  };
}
