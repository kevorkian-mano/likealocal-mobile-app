/// This class is used in the [OnboardingScreen] screen.

// ignore_for_file: must_be_immutable
class OnboardingModel {
  OnboardingModel({
    this.appTitle,
    this.mainHeading,
    this.subHeading,
    this.getStartedText,
    this.loginText,
  }) {
    appTitle = appTitle ?? "LikeALocal";
    mainHeading = mainHeading ?? "Explore like\na local.";
    subHeading =
        subHeading ??
        "The best authentic experiences,\ncurated by the people who live there.";
    getStartedText = getStartedText ?? "Get Started";
    loginText = loginText ?? "Log In";
  }

  String? appTitle;
  String? mainHeading;
  String? subHeading;
  String? getStartedText;
  String? loginText;
}
