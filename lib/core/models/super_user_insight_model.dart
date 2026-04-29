class SuperUserInsight {
  final int totalPinsEarned; // Total times others saved your gems
  final int totalViews;
  final double cityInfluenceRadius; // km
  final int reputationLevel; // 1-10
  final double nextLevelProgress; // 0.0-1.0
  final List<Badge> earnedBadges;
  final List<ContributionTrend> weeklyImpact;

  SuperUserInsight({
    required this.totalPinsEarned,
    required this.totalViews,
    required this.cityInfluenceRadius,
    required this.reputationLevel,
    required this.nextLevelProgress,
    required this.earnedBadges,
    required this.weeklyImpact,
  });

  static SuperUserInsight get mock => SuperUserInsight(
    totalPinsEarned: 142,
    totalViews: 1240,
    cityInfluenceRadius: 15.5,
    reputationLevel: 4,
    nextLevelProgress: 0.75,
    earnedBadges: [
      Badge(name: 'Zamalek Expert', icon: '🏰', color: 0xFF1B3022),
      Badge(name: 'Early Adopter', icon: '🚀', color: 0xFFBDB76B),
      Badge(name: 'Taste Maker', icon: '🍲', color: 0xFFBEAFA7),
    ],
    weeklyImpact: [
      ContributionTrend(day: 'Mon', count: 5),
      ContributionTrend(day: 'Tue', count: 8),
      ContributionTrend(day: 'Wed', count: 12),
      ContributionTrend(day: 'Thu', count: 7),
      ContributionTrend(day: 'Fri', count: 15),
      ContributionTrend(day: 'Sat', count: 22),
      ContributionTrend(day: 'Sun', count: 18),
    ],
  );
}

class Badge {
  final String name;
  final String icon;
  final int color;
  Badge({required this.name, required this.icon, required this.color});
}

class ContributionTrend {
  final String day;
  final int count;
  ContributionTrend({required this.day, required this.count});
}
