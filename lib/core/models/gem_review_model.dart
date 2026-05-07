import 'package:cloud_firestore/cloud_firestore.dart';

/// FR3-8: User-submitted review for a hidden gem
class GemReview {
  final String id;
  final String gemId;
  final String userId;
  final String userName;
  final String avatarUrl;
  final double rating; // 1.0 - 5.0
  final String text;
  final DateTime createdAt;

  GemReview({
    required this.id,
    required this.gemId,
    required this.userId,
    required this.userName,
    this.avatarUrl = '',
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  factory GemReview.fromMap(Map<String, dynamic> map, String docId) {
    return GemReview(
      id: docId,
      gemId: map['gemId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      avatarUrl: map['avatarUrl'] ?? '',
      rating: (map['rating'] ?? 3.0).toDouble(),
      text: map['text'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gemId': gemId,
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GemReview copyWith({double? rating, String? text}) {
    return GemReview(
      id: id,
      gemId: gemId,
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      createdAt: createdAt,
    );
  }
}
