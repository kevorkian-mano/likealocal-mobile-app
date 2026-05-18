import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../theme/text_style_helper.dart';

class GrowthStrategyScreen extends StatelessWidget {
  const GrowthStrategyScreen({super.key});

  static Widget builder(BuildContext context) {
    return const GrowthStrategyScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Growth Strategy',
          style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
            color: const Color(0xFF1B3022),
          ),
        ),
      ),
      body: Consumer2<UserProvider, GemsProvider>(
        builder: (context, userProvider, gemsProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return const Center(child: Text('Please log in to continue.'));
          }

          final userGems = gemsProvider.gems
              .where((g) => g.contributorId == user.id)
              .toList();
          final reputationScore = userProvider.calculateReputationScore(userGems);
          final level = (reputationScore / 500).floor() + 1;
          final nextLevelTarget = level * 500;
          final pointsNeeded = nextLevelTarget - reputationScore;
          final progress = (reputationScore % 500) / 500.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Level Progress Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B3022), Color(0xFF2C4C3B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B3022).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reputation Level $level',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${reputationScore.toStringAsFixed(0)} / $nextLevelTarget XP',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.insights,
                            color: Color(0xFFFFD700),
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFFFFD700),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You need only ${pointsNeeded.toStringAsFixed(0)} more points to unlock Level ${level + 1}! 🚀',
                        style: const TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Active Mission Section
                Text(
                  'Weekly Active Mission',
                  style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                    color: const Color(0xFF1B3022),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.05),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF0),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 1),
                        ),
                        child: const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category Explorer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B3022),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Share a "Romantic" or "Chill" themed place this week to gain an instant +50 Karma Points bonus!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4D6353),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Karma Strategy Playbook
                Text(
                  'Karma Strategy Playbook',
                  style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                    color: const Color(0xFF1B3022),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStrategyTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Upload High Fidelity Images',
                  subtitle: 'Gems with clear high-resolution or stored offline images yield 2x more organic saves by the traveler community (+50 XP per Save).',
                  badgeText: '+50 XP',
                ),
                const SizedBox(height: 16),
                _buildStrategyTile(
                  icon: Icons.lightbulb_outline,
                  title: 'Add a Local\'s Tip',
                  subtitle: 'Providing insider tips (e.g. key codes, secret timings, off-menu dishes) makes your gem twice as likely to get approved (+18 XP per Gem).',
                  badgeText: 'High Approval',
                ),
                const SizedBox(height: 16),
                _buildStrategyTile(
                  icon: Icons.speed_outlined,
                  title: 'Speedy Community Answers',
                  subtitle: 'Respond to traveler inquiries on your gem within 30 minutes to scale up your City Influence Radius (+0.5km bonus).',
                  badgeText: '+0.5km Reach',
                ),
                const SizedBox(height: 16),
                _buildStrategyTile(
                  icon: Icons.trending_up,
                  title: 'Engagement Milestones',
                  subtitle: 'Gems that get over 100 views organically start trending, yielding an automatic +12 Karma points bonus.',
                  badgeText: '+12 XP',
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrategyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33C1C9C1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4EC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B3022), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B3022).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3022),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4D6353),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
