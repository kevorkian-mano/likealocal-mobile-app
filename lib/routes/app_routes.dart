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
import '../presentation/notification_settings_screen/notification_settings_screen.dart';
import '../presentation/manual_payment_screen/manual_payment_screen.dart';
import '../presentation/premium_dashboard_screen/premium_dashboard_screen.dart';
import '../presentation/ai_chatbot_screen/ai_chatbot_screen.dart';
import '../presentation/leaderboard_screen/leaderboard_screen.dart';
import '../presentation/admin_user_management_screen/admin_user_management_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../core/auth_wrapper.dart';
import '../core/role_guard.dart';

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
  static const String notificationSettingsScreen = '/notification_settings_screen';
  static const String manualPaymentScreen = '/manual_payment_screen';
  static const String premiumDashboard = '/premium_dashboard';
  static const String aiChatbotScreen = '/ai_chatbot_screen';
  static const String leaderboardScreen = '/leaderboard_screen';
  static const String adminUserManagement = '/admin_user_management';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    onboardingScreen: OnboardingScreen.builder,
    vibePickerScreen: (context) => const VibePickerScreen(),
    preferenceSummaryScreen: (context) => const RoleGuard(requireAuth: true, child: PreferenceSummaryScreen()),
    pricingPage: PricingPage.builder,
    shareHiddenGemScreen: (context) => const RoleGuard(requireAuth: true, child: ShareHiddenGemScreen()),
    placeDetailsScreen: PlaceDetailsScreen.builder,
    mapsPage: MapsPage.builder, // Guests can view maps
    mapViewPage: MapViewPage.builder, // Guests can view map view
    explorePageWithNotifScreen: ExplorePageWithNotifScreen.builder, // Guests can view explore
    chatWithPostOwnerPage: (context) => RoleGuard(requireAuth: true, child: ChatWithPostOwnerPage.builder(context)),
    userProfilePage: (context) => const RoleGuard(requireAuth: true, child: UserProfilePage()),
    settingsPage: (context) => RoleGuard(requireAuth: true, child: SettingsPage.builder(context)),
    signInPage: (context) => const SignInPage(),
    signUpPage: (context) => const SignUpPage(),
    adminDashboard: (context) => RoleGuard(requireAuth: true, requireAdmin: true, child: AdminDashboardScreen.builder(context)),
    adminModerationQueue: (context) => RoleGuard(requireAuth: true, requireAdmin: true, child: AdminModerationQueueScreen.builder(context)),
    superUserDashboard: (context) => RoleGuard(requireAuth: true, requireSuperUser: true, child: SuperUserDashboardScreen.builder(context)),
    chatListScreen: (context) => RoleGuard(requireAuth: true, child: ChatListScreen.builder(context)),
    chatDetailsScreen: (context) => RoleGuard(requireAuth: true, child: ChatDetailsScreen.builder(context)),
    notificationSettingsScreen: (context) => const RoleGuard(requireAuth: true, child: NotificationSettingsScreen()),
    manualPaymentScreen: (context) => const RoleGuard(requireAuth: true, child: ManualPaymentScreen()),
    premiumDashboard: (context) => const RoleGuard(requireAuth: true, child: PremiumDashboardScreen()),
    aiChatbotScreen: (context) => const RoleGuard(requireAuth: true, child: AIChatbotScreen()),
    leaderboardScreen: (context) => const RoleGuard(requireAuth: true, child: LeaderboardScreen()),
    adminUserManagement: (context) => const RoleGuard(requireAuth: true, requireAdmin: true, child: AdminUserManagementScreen()),
    appNavigationScreen: AppNavigationScreen.builder,
    initialRoute: (context) => const AuthWrapper(),
  };
}
