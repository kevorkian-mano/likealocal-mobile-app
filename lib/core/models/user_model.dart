import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String bio;
  final List<String> selectedVibes;
  final int karmaPoints;
  final bool isPro;
  final bool isSuperUser;
  final bool isAdmin;
  final int chatsStartedToday;
  final DateTime? lastContributionTime;
  final DateTime? lastChatResetDate;


  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl = '',
    this.bio = '',
    this.selectedVibes = const [],
    this.karmaPoints = 0,
    this.isSuperUser = false,
    this.isAdmin = false,
    this.isPro = false,
    this.lastContributionTime,
    this.chatsStartedToday = 0,
    this.lastChatResetDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      bio: map['bio'] ?? '',
      selectedVibes: List<String>.from(map['selectedVibes'] ?? []),
      karmaPoints: map['karmaPoints'] ?? 0,
      isSuperUser: map['isSuperUser'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      isPro: map['isPro'] ?? false,
      lastContributionTime: map['lastContributionTime'] != null 
          ? (map['lastContributionTime'] as Timestamp).toDate() 
          : null,
      chatsStartedToday: map['chatsStartedToday'] ?? 0,
      lastChatResetDate: map['lastChatResetDate'] != null 
          ? (map['lastChatResetDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'selectedVibes': selectedVibes,
      'karmaPoints': karmaPoints,
      'isSuperUser': isSuperUser,
      'isAdmin': isAdmin,
      'isPro': isPro,
      'lastContributionTime': lastContributionTime != null 
          ? Timestamp.fromDate(lastContributionTime!) 
          : null,
      'chatsStartedToday': chatsStartedToday,
      'lastChatResetDate': lastChatResetDate != null 
          ? Timestamp.fromDate(lastChatResetDate!) 
          : null,
    };
  }
}
