import '../models/hidden_gem_model.dart';

/// Helper class for matching gems to user preferences
class GemRankingHelper {
  /// Preference-to-Category Mapping
  /// Maps user preference vibes to gem categories/vibes they should match
  static const Map<String, List<String>> preferenceMapping = {
    'Hidden Cafes': [
      'Cafe', 'Cafes', 'Coffee', 'Bakery', 'Bistro', 'Brunch', 'Roastery'
    ],
    'Street Food': [
      'Street Food', 'Food', 'Market', 'Stalls', 'Local Food', 'Vendor', 'Cart'
    ],
    'Rooftops': [
      'Rooftop', 'Rooftops', 'Terrace', 'Bar', 'Lounge', 'Views', 'Rooftop Bar'
    ],
    'Art & Design': [
      'Art', 'Design', 'Gallery', 'Museum', 'Cultural', 'Creative', 'Street Art',
      'Studio', 'Exhibition'
    ],
    'Nightlife': [
      'Nightlife', 'Bar', 'Club', 'Lounge', 'Nightclub', 'Pub', 'Rooftop Bar',
      'Disco', 'Dance'
    ],
    'History': [
      'History', 'Historical', 'Cultural', 'Museum', 'Heritage', 'Cultural Sites',
      'Ancient', 'Monument', 'Historic'
    ],
    'Parks': [
      'Park', 'Parks', 'Nature', 'Garden', 'Outdoor', 'Green', 'Nature Trail',
      'Botanical'
    ],
    'Budget Gems': [
      'Budget', 'Cheap', 'Affordable', 'Local', 'Casual', 'Inexpensive', 'Street'
    ],
    'Luxury': [
      'Luxury', 'Fine Dining', 'Premium', 'Upscale', 'High-end', 'Elegant',
      'Gourmet', 'Resort'
    ],
    'Chill Vibes': [
      'Chill', 'Relaxation', 'Spa', 'Peaceful', 'Meditation', 'Quiet', 'Lounge',
      'Wellness', 'Yoga'
    ],
  };

  /// Check if a gem matches any of the user's selected preferences
  /// Uses the preference-to-category mapping for intelligent matching
  static bool gemMatchesPreferences(
    HiddenGem gem,
    List<String> userPreferences,
  ) {
    if (userPreferences.isEmpty) return false;

    final gemCategoryLower = gem.category.toLowerCase();
    final gemVibeLower = gem.vibe.toLowerCase();

    for (final userPref in userPreferences) {
      // Get mapped categories for this preference
      final mappedCategories = preferenceMapping[userPref] ?? [];

      // Check if gem category or vibe matches any mapped category
      for (final category in mappedCategories) {
        final categoryLower = category.toLowerCase();
        if (gemCategoryLower.contains(categoryLower) ||
            gemVibeLower.contains(categoryLower)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Separate gems into matching and non-matching based on user preferences
  /// Returns a Map with 'matching' and 'nonMatching' lists
  static Map<String, List<HiddenGem>> separateByPreferences(
    List<HiddenGem> gems,
    List<String> userPreferences,
  ) {
    if (userPreferences.isEmpty) {
      return {
        'matching': [],
        'nonMatching': gems,
      };
    }

    final matching = <HiddenGem>[];
    final nonMatching = <HiddenGem>[];

    for (final gem in gems) {
      if (gemMatchesPreferences(gem, userPreferences)) {
        matching.add(gem);
      } else {
        nonMatching.add(gem);
      }
    }

    return {
      'matching': matching,
      'nonMatching': nonMatching,
    };
  }

  /// Get gems that match user preferences
  static List<HiddenGem> getMatchingGems(
    List<HiddenGem> gems,
    List<String> userPreferences,
  ) {
    return gems.where((gem) => gemMatchesPreferences(gem, userPreferences)).toList();
  }

  /// Calculate match percentage for a gem based on user preferences
  /// Returns a value 0-100 representing how well the gem matches user preferences
  static int calculateMatchPercentage(
    HiddenGem gem,
    List<String> userPreferences,
  ) {
    if (userPreferences.isEmpty) return 0;

    final gemCategoryLower = gem.category.toLowerCase();
    final gemVibeLower = gem.vibe.toLowerCase();
    int matchCount = 0;

    for (final userPref in userPreferences) {
      // Get mapped categories for this preference
      final mappedCategories = preferenceMapping[userPref] ?? [];

      // Check if gem category or vibe matches any mapped category
      for (final category in mappedCategories) {
        final categoryLower = category.toLowerCase();
        if (gemCategoryLower.contains(categoryLower) ||
            gemVibeLower.contains(categoryLower)) {
          matchCount++;
          break; // Count each preference only once
        }
      }
    }

    // Calculate percentage: (matches / total preferences) * 100
    return ((matchCount / userPreferences.length) * 100).round();
  }
}

