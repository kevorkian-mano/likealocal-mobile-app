import 'package:cloud_firestore/cloud_firestore.dart';

enum GemStatus { pending, approved, rejected, draft }

class HiddenGem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String vibe;
  final double rating;
  final String imageUrl;
  final List<String> mediaUrls; // FR3-1: Support multiple images/videos
  final double latitude;
  final double longitude;
  final String localsTip;
  final List<String> recommendedDishes;
  final bool isPremium;
  final bool isTrending;
  final bool isVerified;
  final String contributorId;
  final GemStatus status;
  final String uniqueCode;
  final int views;
  final int saves;
  final int reportCount;
  final DateTime? createdAt;
  final bool isBoosted; // FR12-5
  final DateTime? boostedUntil; // FR12-5
  final bool contributorIsSuperUser; // FR7-4, FR7-5

  HiddenGem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.vibe,
    required this.rating,
    required this.imageUrl,
    this.mediaUrls = const [],
    required this.latitude,
    required this.longitude,
    required this.localsTip,
    required this.recommendedDishes,
    this.isPremium = false,
    this.isTrending = false,
    this.isVerified = false,
    this.contributorId = '',
    this.status = GemStatus.pending,
    this.uniqueCode = '',
    this.views = 0,
    this.saves = 0,
    this.reportCount = 0,
    this.createdAt,
    this.isBoosted = false,
    this.boostedUntil,
    this.contributorIsSuperUser = false,
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
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      localsTip: map['localsTip'] ?? '',
      recommendedDishes: List<String>.from(map['recommendedDishes'] ?? []),
      isPremium: map['isPremium'] ?? false,
      isTrending: map['isTrending'] ?? false,
      isVerified: map['isVerified'] ?? false,
      contributorId: map['contributorId'] ?? '',
      status: GemStatus.values.firstWhere(
        (e) => e.toString() == 'GemStatus.${map['status']}',
        orElse: () => GemStatus.pending,
      ),
      uniqueCode: map['uniqueCode'] ?? '',
      views: map['views'] ?? 0,
      saves: map['saves'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      isBoosted: map['isBoosted'] ?? false,
      boostedUntil: map['boostedUntil'] != null
          ? (map['boostedUntil'] as Timestamp).toDate()
          : null,
      contributorIsSuperUser: map['contributorIsSuperUser'] ?? false,
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
      'mediaUrls': mediaUrls,
      'latitude': latitude,
      'longitude': longitude,
      'localsTip': localsTip,
      'recommendedDishes': recommendedDishes,
      'isPremium': isPremium,
      'isTrending': isTrending,
      'isVerified': isVerified,
      'contributorId': contributorId,
      'status': status.toString().split('.').last,
      'uniqueCode': uniqueCode,
      'views': views,
      'saves': saves,
      'reportCount': reportCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isBoosted': isBoosted,
      'boostedUntil': boostedUntil != null
          ? Timestamp.fromDate(boostedUntil!)
          : null,
      'contributorIsSuperUser': contributorIsSuperUser,
    };
  }

  HiddenGem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? vibe,
    double? rating,
    String? imageUrl,
    List<String>? mediaUrls,
    double? latitude,
    double? longitude,
    String? localsTip,
    List<String>? recommendedDishes,
    bool? isPremium,
    bool? isTrending,
    bool? isVerified,
    String? contributorId,
    GemStatus? status,
    String? uniqueCode,
    int? views,
    int? saves,
    int? reportCount,
    DateTime? createdAt,
    bool? isBoosted,
    DateTime? boostedUntil,
    bool? contributorIsSuperUser,
  }) {
    return HiddenGem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      vibe: vibe ?? this.vibe,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      localsTip: localsTip ?? this.localsTip,
      recommendedDishes: recommendedDishes ?? this.recommendedDishes,
      isPremium: isPremium ?? this.isPremium,
      isTrending: isTrending ?? this.isTrending,
      isVerified: isVerified ?? this.isVerified,
      contributorId: contributorId ?? this.contributorId,
      status: status ?? this.status,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      views: views ?? this.views,
      saves: saves ?? this.saves,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
      isBoosted: isBoosted ?? this.isBoosted,
      boostedUntil: boostedUntil ?? this.boostedUntil,
      contributorIsSuperUser:
          contributorIsSuperUser ?? this.contributorIsSuperUser,
    );
  }

  bool get isApproved => status == GemStatus.approved;
}
