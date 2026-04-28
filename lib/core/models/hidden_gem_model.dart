class HiddenGem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String vibe;
  final double rating;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String localsTip;
  final List<String> recommendedDishes;
  final bool isPremium;
  final bool isTrending;
  final String contributorId;
  final bool isApproved;
  final int views;
  final int saves;

  HiddenGem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.vibe,
    required this.rating,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.localsTip,
    required this.recommendedDishes,
    this.isPremium = false,
    this.isTrending = false,
    this.contributorId = '',
    this.isApproved = false,
    this.views = 0,
    this.saves = 0,
  });

  factory HiddenGem.fromMap(Map<String, dynamic> map, String documentId) {
    return HiddenGem(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      vibe: map['vibe'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      localsTip: map['localsTip'] ?? '',
      recommendedDishes: List<String>.from(map['recommendedDishes'] ?? []),
      isPremium: map['isPremium'] ?? false,
      isTrending: map['isTrending'] ?? false,
      contributorId: map['contributorId'] ?? '',
      isApproved: map['isApproved'] ?? false,
      views: map['views'] ?? 0,
      saves: map['saves'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'vibe': vibe,
      'rating': rating,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'localsTip': localsTip,
      'recommendedDishes': recommendedDishes,
      'isPremium': isPremium,
      'isTrending': isTrending,
      'contributorId': contributorId,
      'isApproved': isApproved,
      'views': views,
      'saves': saves,
    };
  }
}
