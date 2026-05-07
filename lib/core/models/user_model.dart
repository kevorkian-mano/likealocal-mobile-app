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
  final int contributionStreak;
  final List<String> badges;
  final List<String> savedGems; // FR3-3
  final bool acceptsMessages; // FR5-2
  final bool isDndEnabled;    // FR5-3
  final int dndStartHour;     // FR5-3 (0-23)
  final int dndEndHour;       // FR5-3 (0-23)
  final List<String> blockedUsers; // FR5-5
  final bool isBanned;             // FR11-6


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
    this.contributionStreak = 0,
    this.badges = const [],
    this.savedGems = const [],
    this.acceptsMessages = true,
    this.isDndEnabled = false,
    this.dndStartHour = 22,
    this.dndEndHour = 8,
    this.blockedUsers = const [],
    this.isBanned = false,
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
      contributionStreak: map['contributionStreak'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      savedGems: List<String>.from(map['savedGems'] ?? []),
      acceptsMessages: map['acceptsMessages'] ?? true,
      isDndEnabled: map['isDndEnabled'] ?? false,
      dndStartHour: map['dndStartHour'] ?? 22,
      dndEndHour: map['dndEndHour'] ?? 8,
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      isBanned: map['isBanned'] ?? false,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? bio,
    List<String>? selectedVibes,
    int? karmaPoints,
    bool? isSuperUser,
    bool? isAdmin,
    bool? isPro,
    DateTime? lastContributionTime,
    int? chatsStartedToday,
    DateTime? lastChatResetDate,
    int? contributionStreak,
    List<String>? badges,
    List<String>? savedGems,
    bool? acceptsMessages,
    bool? isDndEnabled,
    int? dndStartHour,
    int? dndEndHour,
    List<String>? blockedUsers,
    bool? isBanned,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      selectedVibes: selectedVibes ?? this.selectedVibes,
      karmaPoints: karmaPoints ?? this.karmaPoints,
      isSuperUser: isSuperUser ?? this.isSuperUser,
      isAdmin: isAdmin ?? this.isAdmin,
      isPro: isPro ?? this.isPro,
      lastContributionTime: lastContributionTime ?? this.lastContributionTime,
      chatsStartedToday: chatsStartedToday ?? this.chatsStartedToday,
      lastChatResetDate: lastChatResetDate ?? this.lastChatResetDate,
      contributionStreak: contributionStreak ?? this.contributionStreak,
      badges: badges ?? this.badges,
      savedGems: savedGems ?? this.savedGems,
      acceptsMessages: acceptsMessages ?? this.acceptsMessages,
      isDndEnabled: isDndEnabled ?? this.isDndEnabled,
      dndStartHour: dndStartHour ?? this.dndStartHour,
      dndEndHour: dndEndHour ?? this.dndEndHour,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      isBanned: isBanned ?? this.isBanned,
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
      'contributionStreak': contributionStreak,
      'badges': badges,
      'savedGems': savedGems,
      'acceptsMessages': acceptsMessages,
      'isDndEnabled': isDndEnabled,
      'dndStartHour': dndStartHour,
      'dndEndHour': dndEndHour,
      'blockedUsers': blockedUsers,
      'isBanned': isBanned,
    };
  }

}
