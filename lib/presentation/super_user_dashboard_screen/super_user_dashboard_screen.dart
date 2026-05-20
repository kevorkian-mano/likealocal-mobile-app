import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../core/models/user_model.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/app_export.dart';
import '../../core/models/super_user_insight_model.dart';
import '../../widgets/safe_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SuperUserDashboardScreen extends StatelessWidget {
  const SuperUserDashboardScreen({super.key});

  static Widget builder(BuildContext context) {
    return const SuperUserDashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, GemsProvider>(
      builder: (context, userProvider, gemsProvider, child) {
        final user = userProvider.user;

        if (user == null || !user.isSuperUser) {
          return _buildAccessDenied(context);
        }

        // Real Data Engine (FR5-6)
        final userGems = gemsProvider.gems
            .where((g) => g.contributorId == user.id)
            .toList();
        final totalViews = userGems.fold<int>(0, (sum, g) => sum + g.views);
        final totalSaves = userGems.fold<int>(0, (sum, g) => sum + g.saves);
        final totalReach =
            totalViews + (totalSaves * 5); // Saves weighted higher

        final approvedCount = userGems
            .where((g) => g.status == GemStatus.approved)
            .length;
        final trendingCount = userGems.where((g) => g.isTrending).length;
        final karma = user.karmaPoints;
        
        // Calculate the score from the formula implemented in UserProvider (FR7-2)
        final reputationScore = userProvider.calculateReputationScore(userGems);
        
        final level = (reputationScore / 500).floor() + 1; // Assuming every 500 is a level, or stick to 100
        final progress = (reputationScore % 500) / 500.0;

        // Influence logic: 1km per 2 approved gems
        final influenceRadius = (approvedCount / 2).clamp(1.0, 5.0);
        final insights = SuperUserInsight(
          totalPinsEarned: totalSaves,
          totalViews: totalViews,
          cityInfluenceRadius: influenceRadius,
          reputationLevel: level,
          nextLevelProgress: progress,
          earnedBadges: _buildBadges(
            user,
            userGems,
            approvedCount,
            trendingCount,
            totalSaves,
          ),
          weeklyImpact: [], // Weekly trend data
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF9F7F2),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReputationCard(
                        level,
                        progress,
                        totalReach,
                        reputationScore,
                      ),
                      const SizedBox(height: 24),
                      _buildSuperActions(
                        context,
                        gemsProvider.pendingGems.length,
                      ),
                      const SizedBox(height: 32),
                      _buildCityInfluenceSection(influenceRadius),
                      const SizedBox(height: 32),
                      _buildImpactChart(totalViews, totalSaves),
                      const SizedBox(height: 32),
                      _buildCommunityEngagement(context),
                      const SizedBox(height: 32),
                      _buildBadgesSection(insights),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_person_outlined,
                size: 80,
                color: Color(0xFF1B3022),
              ),
              const SizedBox(height: 24),
              Text(
                'Super User Access Only',
                style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                  color: const Color(0xFF1B3022),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share more hidden gems and earn 500 karma points to unlock your local impact dashboard.',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: const Color(0xFF4D6353),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3022),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Keep Exploring',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFFF9F7F2),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${user.fullName.split(' ').first}\'s Local Impact',
          style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
            color: Color(0xFF1B3022),
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildReputationCard(
    int level,
    double progress,
    int totalReach,
    double reputationScore,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B3022),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.2 * value),
                blurRadius: 30 * value,
                spreadRadius: 2 * value,
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
                        'Level $level',
                        style: TextStyleHelper.instance.title20BoldOutfit
                            .copyWith(color: Colors.white),
                      ),
                      Row(
                        children: [
                          Text(
                            'Reputation Score: ${reputationScore.toStringAsFixed(0)}',
                            style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _showReputationInfo(context),
                            child: const Icon(Icons.info_outline, color: Colors.white70, size: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFFD700),
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress * value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFBDB76B)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${(progress * 100).toInt()}% to next level',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Local impact: $totalReach',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Badge> _buildBadges(
    UserModel user,
    List<HiddenGem> userGems,
    int approvedCount,
    int trendingCount,
    int totalSaves,
  ) {
    final badges = <Badge>[
      Badge(name: 'Local Legend', icon: '🏆', color: 0xFF1B3022),
    ];

    if (approvedCount >= 3) {
      badges.add(
        Badge(name: 'Trusted Publisher', icon: '✅', color: 0xFF3E5641),
      );
    }
    if (totalSaves >= 25) {
      badges.add(
        Badge(name: 'Community Magnet', icon: '📌', color: 0xFFBDB76B),
      );
    }
    if (trendingCount > 0) {
      badges.add(Badge(name: 'Trend Setter', icon: '🔥', color: 0xFFFFD700));
    }
    if (user.karmaPoints >= 1000) {
      badges.add(Badge(name: 'High Karma', icon: '✨', color: 0xFFBEAFA7));
    }

    return badges;
  }

  Widget _buildSuperActions(BuildContext context, int pendingCount) {
    return Column(
      children: [
        Builder(
          builder: (context) => _buildActionTile(
            icon: Icons.fact_check_outlined,
            title: 'Moderation Queue',
            subtitle: '$pendingCount gems waiting for review',
            color: const Color(0xFF3E5641),
            badge: pendingCount > 0 ? '$pendingCount' : null,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminModerationQueue),
          ),
        ),
        const SizedBox(height: 12),
        // FR12-5: Boost a contribution
        Builder(
          builder: (context) => _buildActionTile(
            icon: Icons.rocket_launch_outlined,
            title: 'Boost a Gem',
            subtitle: 'Elevate your gem to top of discovery for 24h',
            color: const Color(0xFFBDB76B),
            onTap: () => _showBoostDialog(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.insights_outlined,
          title: 'Growth Strategy',
          subtitle: 'Tips to increase your local reach',
          color: const Color(0xFF4D6353),
          onTap: () => Navigator.pushNamed(context, AppRoutes.growthStrategy),
        ),
        const SizedBox(height: 12),
        // FR12-4: View pending chat requests
        _buildActionTile(
          icon: Icons.forum_outlined,
          title: 'Community Inquiries',
          subtitle: 'Help travelers with their questions',
          color: const Color(0xFF1B3022),
          badge: '2 New',
          onTap: () => Navigator.pushNamed(context, AppRoutes.chatListScreen),
        ),
      ],
    );
  }

  // FR12-5: Boost gem dialog
  void _showBoostDialog(BuildContext context) {
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    final myGems = gemsProvider.gems
        .where((g) => g.contributorId == userId && g.isApproved)
        .toList();

    if (myGems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No approved gems to boost yet. Share more hidden gems first!',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rocket_launch_outlined,
                      color: Color(0xFFBDB76B),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Select Gem to Boost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3022),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Boosted gems appear at the top of discovery for 24 hours.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: myGems.length,
              itemBuilder: (ctx, i) {
                final gem = myGems[i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SafeImage(
                      imageUrl: gem.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFD7E8DE),
                        child: const Icon(Icons.place),
                      ),
                    ),
                  ),
                  title: Text(
                    gem.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    gem.isBoosted ? '🚀 Already boosted' : gem.category,
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: gem.isBoosted
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFBDB76B),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await gemsProvider.boostGem(gem.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '"${gem.name}" is now boosted for 24 hours! 🚀',
                                  ),
                                  backgroundColor: Color(0xFF1B3022),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Boost',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x33C1C9C1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleHelper.instance.body14BoldInter.copyWith(
                      color: const Color(0xFF191C1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyleHelper.instance.body12MediumInter.copyWith(
                      color: const Color(0xFF4D6353),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCityInfluenceSection(double radius) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City Influence Area',
          style: TextStyleHelper.instance.title18SemiBoldInter,
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            image: const DecorationImage(
              image: CachedNetworkImageProvider(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                _RadarScanOverlay(),
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      return Container(
                        width: (100 * radius) * (1 + 0.1 * value),
                        height: (100 * radius) * (1 + 0.1 * value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFFFD700,
                            ).withOpacity(0.5 * (1 - value)),
                            width: 3,
                          ),
                          color: const Color(0xFFFFD700).withOpacity(0.1),
                        ),
                      );
                    },
                  ),
                ),
                const Center(
                  child: Icon(Icons.my_location, color: Colors.white, size: 24),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3022).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${radius.toStringAsFixed(1)} km Radius',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactChart(int views, int saves) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0x33C1C9C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Analytics',
            style: TextStyleHelper.instance.title18SemiBoldInter,
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String text = value == 0 ? 'Views' : 'Saves';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: TextStyleHelper.instance.label10MediumInter
                                .copyWith(color: const Color(0xFF4D6353)),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: views.toDouble(),
                        color: const Color(0xFF1B3022),
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: saves.toDouble(),
                        color: const Color(0xFFFFD700),
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityEngagement(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Traveler Questions', style: TextStyleHelper.instance.title18SemiBoldInter),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
              child: Text('Urgent', style: TextStyle(color: Colors.red[900], fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: 'default',
          )
          .collection('chats')
          .where('participants', arrayContains: user.id)
          .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Color(0xFF1B3022)),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyQuestionsPlaceholder();
            }

            // Filter chats that have relatedGemName
            final inquiryChats = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final relatedGem = data['relatedGemName'] as String?;
              return relatedGem != null && relatedGem.isNotEmpty;
            }).toList();

            if (inquiryChats.isEmpty) {
              return _buildEmptyQuestionsPlaceholder();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: inquiryChats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = inquiryChats[index];
                final data = doc.data() as Map<String, dynamic>;
                final participants = List<String>.from(data['participants'] ?? []);
                final travelerId = participants.firstWhere((id) => id != user.id, orElse: () => '');
                
                final travelerName = (data['participantNames'] as Map<String, dynamic>?)?[travelerId] ?? 'Traveler';
                final questionText = data['lastMessage'] ?? 'No messages yet';
                final gemName = data['relatedGemName'] ?? 'Hidden Gem';
                
                final lastTime = data['lastMessageTime'] as Timestamp?;
                String timeStr = 'Just now';
                if (lastTime != null) {
                  final diff = DateTime.now().difference(lastTime.toDate());
                  if (diff.inMinutes < 60) {
                    timeStr = '${diff.inMinutes}m ago';
                  } else if (diff.inHours < 24) {
                    timeStr = '${diff.inHours}h ago';
                  } else {
                    timeStr = '${diff.inDays}d ago';
                  }
                }

                return _buildQuestionCard(
                  context,
                  travelerName,
                  questionText,
                  gemName,
                  timeStr,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyQuestionsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.forum_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No traveler questions yet.',
              style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, String name, String question, String gemName, String time) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33C1C9C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFFE8F2E9), child: Text(name[0], style: const TextStyle(color: Color(0xFF1B3022)))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyleHelper.instance.body14BoldInter),
                    Text('Regarding $gemName', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: TextStyleHelper.instance.body14MediumInter.copyWith(color: const Color(0xFF4D6353), height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chatListScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3022),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Answer Question', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(SuperUserInsight insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyleHelper.instance.title18SemiBoldInter,
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: insights.earnedBadges
              .map((badge) => _buildBadgeItem(badge))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(Badge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(badge.color).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            badge.name,
            style: TextStyleHelper.instance.body14BoldInter.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showReputationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFFD700)),
            const SizedBox(width: 12),
            Text('Score Breakdown', style: TextStyleHelper.instance.title18SemiBoldInter),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRepRow('Karma Points', '0.45 pts/each'),
            _buildRepRow('Approved Gems', '18 pts/each'),
            _buildRepRow('Gem Views', '0.02 pts/each'),
            _buildRepRow('Gem Saves', '0.25 pts/each'),
            _buildRepRow('Trending Gems', '12 pts/each'),
            const SizedBox(height: 16),
            const Text(
              'Your reputation reflects your standing as a trusted local guardian.',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it', style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildRepRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4D6353))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
        ],
      ),
    );
  }
}

class _RadarScanOverlay extends StatefulWidget {
  @override
  __RadarScanOverlayState createState() => __RadarScanOverlayState();
}

class __RadarScanOverlayState extends State<_RadarScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _RadarPainter(_controller.value),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double angle;
  _RadarPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Color(0xFFFFD700).withOpacity(0.0),
          Color(0xFFFFD700).withOpacity(0.4),
        ],
        stops: [0.9, 1.0],
        transform: GradientRotation(angle * 6.28),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
