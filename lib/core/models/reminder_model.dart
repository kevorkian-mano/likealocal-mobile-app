import 'package:cloud_firestore/cloud_firestore.dart';

/// FR3-7: User reminder to visit a place when nearby
class Reminder {
  final String id;
  final String userId;
  final String gemId;
  final String gemName;
  final double latitude;
  final double longitude;
  final double radiusMeters; // Geofence radius (default 500m)
  final String message;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? triggeredAt; // When the reminder was shown

  Reminder({
    required this.id,
    required this.userId,
    required this.gemId,
    required this.gemName,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 500.0,
    this.message = '',
    this.isActive = true,
    required this.createdAt,
    this.triggeredAt,
  });

  factory Reminder.fromMap(Map<String, dynamic> map, String docId) {
    return Reminder(
      id: docId,
      userId: map['userId'] ?? '',
      gemId: map['gemId'] ?? '',
      gemName: map['gemName'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      radiusMeters: (map['radiusMeters'] ?? 500.0).toDouble(),
      message: map['message'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      triggeredAt: map['triggeredAt'] != null
          ? (map['triggeredAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gemId': gemId,
      'gemName': gemName,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'message': message,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'triggeredAt': triggeredAt != null
          ? Timestamp.fromDate(triggeredAt!)
          : null,
    };
  }

  Reminder copyWith({bool? isActive, DateTime? triggeredAt}) {
    return Reminder(
      id: id,
      userId: userId,
      gemId: gemId,
      gemName: gemName,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      message: message,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }
}
