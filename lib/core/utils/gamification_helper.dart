import '../models/user_model.dart';

class GamificationHelper {
  static Map<String, dynamic> updateStreakAndBadges(UserModel user) {
    int currentStreak = user.contributionStreak;
    List<String> currentBadges = List.from(user.badges);
    
    final now = DateTime.now();
    final lastContrib = user.lastContributionTime;

    // 1. Update Streak
    if (lastContrib != null) {
      final difference = now.difference(lastContrib).inDays;
      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        currentStreak = 1; // Reset streak if missed a day
      }
    } else {
      currentStreak = 1;
    }

    // 2. Award Badges
    if (currentStreak >= 3 && !currentBadges.contains('3_day_streak')) {
      currentBadges.add('3_day_streak');
    }
    if (currentStreak >= 7 && !currentBadges.contains('7_day_streak')) {
      currentBadges.add('7_day_streak');
    }
    
    // Milestone badges
    // Assuming we track total contributions elsewhere, but for now we can use karma
    if (user.karmaPoints >= 100 && !currentBadges.contains('rising_star')) {
      currentBadges.add('rising_star');
    }
    if (user.karmaPoints >= 500 && !currentBadges.contains('local_legend')) {
      currentBadges.add('local_legend');
    }

    return {
      'streak': currentStreak,
      'badges': currentBadges,
    };
  }
}
