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
  final double activeUserRatio; // FR11-8
  final int bannedUserCount; // FR11-6
  final List<String> staleGemSuggestions; // FR11-8

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
    this.activeUserRatio = 0.85,
    this.bannedUserCount = 3,
    this.staleGemSuggestions = const [
      'Sunset Point (No activity)',
      'Old Alleyway (Low rating)',
    ],
  });
}
