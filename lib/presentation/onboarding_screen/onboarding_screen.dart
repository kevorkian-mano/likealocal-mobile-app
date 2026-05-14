import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
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
                            .copyWith(color: appTheme.sunlightGold),
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
                      SizedBox(height: 44.h),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: appTheme.sunlightGold.withOpacity(
                                        0.2 * (1 - value.abs()),
                                      ),
                                      blurRadius: 15 * (1 - value.abs()),
                                      spreadRadius: 5 * (1 - value.abs()),
                                    ),
                                  ],
                                ),
                                child: CustomButton(
                                  text: 'Explore the City',
                                  backgroundColor: appTheme.sunlightGold,
                                  textColor: appTheme.midnightPine,
                                  borderRadius: 12,
                                  fontFamily: 'Outfit',
                                  fontSize: 18.fSize,
                                  fontWeight: FontWeight.w700,
                                  padding: EdgeInsets.symmetric(vertical: 18.h),
                                  margin: EdgeInsets.zero,
                                  width: double.infinity,
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                      AppRoutes.explorePageWithNotifScreen,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: provider.onGetStartedPressed,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign Up to Contribute',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Outfit',
                                      fontSize: 16.fSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                      Center(
                        child: GestureDetector(
                          onTap: provider.onLoginPressed,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyleHelper
                                      .instance
                                      .body14MediumInter,
                                ),
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyleHelper
                                      .instance
                                      .body14BoldInter
                                      .copyWith(color: appTheme.sunlightGold),
                                ),
                              ],
                            ),
                          ),
                        ),
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
