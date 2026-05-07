class AdminInsight {
  final double vibeSoulGastronomy;
  final double vibeSoulArt;
  final double vibeSoulHistory;
  final double vibeSoulNightlife;
  final double vibeSoulNature;

  final List<double> discoveryVelocity; // Last 7 days submissions
  final double authenticityScore; // 0.0 to 1.0
  final int pendingModerationCount;
  final int conversionRate; // Percentage

  AdminInsight({
    required this.vibeSoulGastronomy,
    required this.vibeSoulArt,
    required this.vibeSoulHistory,
    required this.vibeSoulNightlife,
    required this.vibeSoulNature,
    required this.discoveryVelocity,
    required this.authenticityScore,
    required this.pendingModerationCount,
    required this.conversionRate,
  });

}
