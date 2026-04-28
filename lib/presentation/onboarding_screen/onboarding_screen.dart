import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import './provider/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({Key? key}) : super(key: key);

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
              image: DecorationImage(
                image: AssetImage(ImageConstant.imgScenicLocalStreet),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66661B30), appTheme.colorBF1B30],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 32.h, top: 60.h),
                      child: Text(
                        provider.onboardingModel.appTitle ?? 'LikeALocal',
                        style: TextStyleHelper
                            .instance
                            .headline30ExtraBoldPlusJakartaSans
                            .copyWith(height: 1.27),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 116.h),
                      alignment: Alignment.centerRight,
                      child: CustomImageView(
                        imagePath: ImageConstant.imgDecorativeBlurs,
                        height: 192.h,
                        width: 112.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 40.h,
                        right: 24.h,
                        bottom: 18.h,
                      ),
                      width: double.infinity,
                      height: 350.h,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(top: 16.h),
                              child: CustomImageView(
                                imagePath: ImageConstant.imgOverlayBlur,
                                height: 192.h,
                                width: 112.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.h),
                            margin: EdgeInsets.only(left: 24.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.onboardingModel.mainHeading ??
                                      'Explore like\na local.',
                                  style: TextStyleHelper
                                      .instance
                                      .display48BoldPlusJakartaSans
                                      .copyWith(height: 1.25),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 16.h),
                                  child: Text(
                                    provider.onboardingModel.subHeading ??
                                        'The best authentic experiences,\ncurated by the people who live there.',
                                    style: TextStyleHelper
                                        .instance
                                        .title18RegularInter
                                        .copyWith(height: 1.56),
                                  ),
                                ),
                                CustomButton(
                                  text:
                                      provider.onboardingModel.getStartedText ??
                                      'Get Started',
                                  backgroundColor: appTheme.gray_300_01,
                                  textColor: appTheme.gray_900_01,
                                  borderRadius: 34,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 18.fSize,
                                  fontWeight: FontWeight.w700,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 20.h,
                                    horizontal: 30.h,
                                  ),
                                  margin: EdgeInsets.only(top: 44.h),
                                  width: double.infinity,
                                  onPressed: provider.onGetStartedPressed,
                                ),
                                GestureDetector(
                                  onTap: provider.onLoginPressed,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 24.h),
                                    alignment: Alignment.center,
                                    child: Text(
                                      provider.onboardingModel.loginText ??
                                          'Log In',
                                      style: TextStyleHelper
                                          .instance
                                          .body14MediumInter
                                          .copyWith(height: 1.21),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
