import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class PreferenceSummaryScreen extends StatelessWidget {
  const PreferenceSummaryScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const PreferenceSummaryScreen();
  }

  @override
  Widget build(BuildContext context) {
    final vibes = ['Gastronomy Enthusiast', 'Historical Soul', 'Nightlife Seeker'];

    return Scaffold(
      backgroundColor: Color(0xFF1B3022), // Midnight Pine
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(seconds: 2),
              builder: (context, value, child) {
                return Icon(Icons.psychology, color: Color(0xFFFFD700).withOpacity(value), size: 80);
              },
            ),
            SizedBox(height: 24),
            Text(
              'AI Profile Initialized',
              style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              'Based on your choices, we\'ve identified your travel DNA.',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(color: Colors.white70),
            ),
            SizedBox(height: 48),
            ...vibes.asMap().entries.map((e) => _buildAnimatedVibeChip(e.value, e.key)).toList(),
            SizedBox(height: 64),
            CustomButton(
              text: 'Start Exploring',
              onTap: () => Navigator.pushNamed(context, AppRoutes.explorePageWithNotifScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedVibeChip(String text, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Interval(index * 0.2, 1.0, curve: Curves.easeOut),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: _buildVibeChip(text),
          ),
        );
      },
    );
  }

  Widget _buildVibeChip(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 20),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
