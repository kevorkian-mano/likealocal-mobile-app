import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/onboarding_model.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingModel onboardingModel = OnboardingModel();

  void onGetStartedPressed() {
    // Navigate to the next screen for new users (onboarding flow)
    // Since no specific route is mentioned, navigate to the share hidden gem screen
    NavigatorService.pushNamed(AppRoutes.signUpPage);
  }

  void onLoginPressed() {
    // Navigate to login screen for existing users
    // Since no login screen is available in routes, show a placeholder message
    // In a real app, this would navigate to login screen
    NavigatorService.pushNamed(AppRoutes.signInPage);
  }

  void initialize() {
    // Initialize any required data
    onboardingModel = OnboardingModel();
    notifyListeners();
  }
}
