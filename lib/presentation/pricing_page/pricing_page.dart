import '../../core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  static Widget builder(BuildContext context) {
    return const PricingPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF191C1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Unlock Your Potential',
          style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
            color: Color(0xFF191C1A),
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          final isPro = user?.isPro ?? false;
          final isSuper = user?.isSuperUser ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 32),
                _buildPlanCard(
                  context,
                  title: 'Free Explorer',
                  price: 'EGP 0',
                  subtitle: 'Perfect for casual discovery',
                  features: [
                    'Browse 100+ Hidden Gems',
                    'Save up to 3 personal pins',
                    'Set 1 location reminder',
                    'Basic search & filters',
                  ],
                  isCurrent: !isPro && !isSuper,
                ),
                SizedBox(height: 20),
                _buildPlanCard(
                  context,
                  title: 'Premium Nomad',
                  price: 'EGP 150/mo',
                  subtitle: 'Unlock the full experience',
                  features: [
                    'Everything in Free',
                    'Unlimited Saved Pins',
                    'Unlimited Location Reminders',
                    'AI-Powered Personal Itineraries',
                    'Offline Neighborhood Map Downloads',
                    'Exclusive Super User Tips',
                  ],
                  isPopular: true,
                  isCurrent: isPro && !isSuper,
                  buttonText: 'Upgrade Now',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.manualPaymentScreen);
                  },
                ),
                SizedBox(height: 20),
                _buildPlanCard(
                  context,
                  title: 'Local Legend',
                  price: 'Free (Earned)',
                  subtitle: 'The ultimate status for contributors',
                  features: [
                    'Everything in Premium',
                    'Instant Publishing (No Moderation)',
                    '"Local Legend" Profile Badge',
                    'Contribution Impact Dashboard',
                    'Access to Super User Community',
                  ],
                  isSuperUser: true,
                  isCurrent: isSuper,
                  buttonText: isSuper
                      ? 'You are a Legend'
                      : 'Learn How to Earn',
                ),
                SizedBox(height: 40),
                _buildPhilosophySection(),
                SizedBox(height: 40),
                Text(
                  'Secure payment via InstaPay, Telda, or Vodafone Cash.',
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.label10MediumInter.copyWith(
                    color: Color(0xFF4D6353),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhilosophySection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Color(0xFF1B3022).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.diversity_3_outlined, color: Color(0xFF1B3022), size: 32),
          SizedBox(height: 16),
          Text(
            'The LikeALocal Philosophy',
            style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
              color: Color(0xFF1B3022),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'We believe cities are best experienced through souls, not search engines. Our AI doesn\'t just find "spots"; it learns your "vibe" and matches you with gems curated by trusted Local Legends.',
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.body14MediumInter.copyWith(
              color: Color(0xFF4D6353),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE8F2E9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star_rounded, color: Color(0xFF1B3022), size: 48),
        ),
        SizedBox(height: 16),
        Text(
          'Go Beyond the Guidebook',
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
            color: Color(0xFF191C1A),
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String subtitle,
    required List<String> features,
    bool isPopular = false,
    bool isSuperUser = false,
    bool isCurrent = false,
    String buttonText = 'Continue',
    VoidCallback? onTap,
  }) {
    final primaryColor = isSuperUser ? Color(0xFFBDB76B) : Color(0xFF1B3022);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPopular ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isPopular ? primaryColor : Color(0x33C1C9C1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Text(
            title,
            style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
              color: isPopular ? Colors.white : Color(0xFF191C1A),
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyleHelper.instance.body14MediumInter.copyWith(
              color: isPopular
                  ? Colors.white.withOpacity(0.7)
                  : Color(0xFF4D6353),
            ),
          ),
          SizedBox(height: 16),
          Text(
            price,
            style: TextStyleHelper.instance.display36ExtraBoldOutfit.copyWith(
              color: isPopular ? Colors.white : Color(0xFF191C1A),
              fontSize: 28,
            ),
          ),
          SizedBox(height: 24),
          Divider(
            color: isPopular
                ? Colors.white.withOpacity(0.2)
                : Color(0x33C1C9C1),
          ),
          SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isPopular ? Colors.white : Color(0xFF3E5641),
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyleHelper.instance.body14MediumInter
                          .copyWith(
                            color: isPopular ? Colors.white : Color(0xFF191C1A),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: isCurrent ? null : onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isPopular ? Colors.white : primaryColor,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: Text(
                  isCurrent ? 'Current Plan' : buttonText,
                  style: TextStyleHelper.instance.body14BoldInter.copyWith(
                    color: isPopular ? primaryColor : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
