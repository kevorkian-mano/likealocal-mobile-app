import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './provider/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<OnboardingProvider>(
      create: (context) => OnboardingProvider(),
      child: OnboardingScreen(),
    );
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: appTheme.midnightPine,
              image: DecorationImage(
                image: AssetImage(ImageConstant.imgScenicLocalStreet),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appTheme.midnightPine.withOpacity(0.2),
                    appTheme.midnightPine.withOpacity(0.9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.onboardingModel.appTitle ?? 'LikeALocal',
                        style: TextStyleHelper
                            .instance
                            .headline30ExtraBoldOutfit
                            .copyWith(color: Colors.white),
                      ),
                      Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 1000),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Text(
                                provider.onboardingModel.mainHeading ??
                                    'Explore like\na local.',
                                style: TextStyleHelper
                                    .instance
                                    .display48BoldOutfit
                                    .copyWith(height: 1.1),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 1000),
                        curve: Interval(0.5, 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Text(
                                provider.onboardingModel.subHeading ??
                                    'The best authentic experiences,\ncurated by the people who live there.',
                                style: TextStyleHelper
                                    .instance
                                    .title18RegularInter
                                    .copyWith(
                                      height: 1.5,
                                      color: appTheme.paleSand.withOpacity(0.8),
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 36.h),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Column(
                              children: [
                                // 1. Sign Up to Contribute (Dark Green Gradient Capsule Button)
                                GestureDetector(
                                  onTap: provider.onGetStartedPressed,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    decoration: ShapeDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment(0.46, -0.46),
                                        end: Alignment(0.54, 1.46),
                                        colors: [
                                          Color(0xFF1B3022),
                                          Color(0xFF2D4B39),
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: const Color(0x331B3022),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Join the Community',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.fSize,
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // 2. Explore the City (White Text Button)
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                      AppRoutes.explorePageWithNotifScreen,
                                    );
                                  },
                                  child: Text(
                                    'Explore the City',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.fSize,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),

                                // 3. Log In (White Text Button)
                                TextButton(
                                  onPressed: provider.onLoginPressed,
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.fSize,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),

                                // 4. See Premium Nomad Benefits (Underlined link)
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.pricingPage,
                                  ),
                                  child: Text(
                                    'See Premium Nomad Benefits',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: 'Inter',
                                      fontSize: 14.fSize,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
