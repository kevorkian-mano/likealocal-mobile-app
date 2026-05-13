import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../widgets/custom_button.dart';

class PremiumUpgradeSheet extends StatelessWidget {
  const PremiumUpgradeSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.h)),
      ),
      padding: EdgeInsets.fromLTRB(24.h, 12.h, 24.h, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.h,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.h),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: appTheme.midnightPine.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: appTheme.midnightPine, size: 40.h),
          ),
          SizedBox(height: 16.h),
          Text(
            'Limit Reached!',
            style: TextStyleHelper.instance.title24ExtraBoldOutfit,
          ),
          SizedBox(height: 8.h),
          Text(
            'Free users can save up to 3 pins. Upgrade to Premium to unlock unlimited discoveries!',
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.body14MediumInter.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: 32.h),
          _buildFeatureRow(Icons.all_inclusive, 'Unlimited Saved Pins & Reminders'),
          _buildFeatureRow(Icons.auto_awesome, 'AI Personalized Itineraries'),
          _buildFeatureRow(Icons.download_for_offline, 'Offline Neighborhood Maps'),
          _buildFeatureRow(Icons.verified, 'Exclusive Super User Tips'),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'Upgrade to Premium Nomad',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.pricingPage);
            },
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(icon, color: appTheme.midnightPine, size: 20.h),
          SizedBox(width: 16.h),
          Text(
            text,
            style: TextStyleHelper.instance.body14BoldInter,
          ),
        ],
      ),
    );
  }
}
