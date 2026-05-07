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
