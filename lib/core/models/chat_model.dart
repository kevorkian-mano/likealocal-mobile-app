import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromMap(
    Map<String, dynamic> map,
    String documentId,
    String currentUserId,
  ) {
    return ChatMessage(
      id: documentId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isMe: map['senderId'] == currentUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ChatPreview {
  final String id;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String relatedGemName;
  final String targetUserId; // FR5-5: the other participant's user ID

  ChatPreview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.relatedGemName,
    this.targetUserId = '',
  });

  factory ChatPreview.fromMap(
    Map<String, dynamic> map,
    String documentId,
    String currentUserId,
  ) {
    // Determine the other participant's name and avatar
    final participantNames =
        map['participantNames'] as Map<String, dynamic>? ?? {};
    final participantAvatars =
        map['participantAvatars'] as Map<String, dynamic>? ?? {};

    // Find the other user's ID
    final participants = List<String>.from(map['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final unreadMap = map['unreadCount'] as Map<String, dynamic>? ?? {};

    return ChatPreview(
      id: documentId,
      userName: participantNames[otherUserId] ?? 'Unknown User',
      userAvatar: participantAvatars[otherUserId] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : DateTime.now(),
      unreadCount: unreadMap[currentUserId] ?? 0,
      relatedGemName: map['relatedGemName'] ?? '',
      targetUserId: otherUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'relatedGemName': relatedGemName,
    };
  }
}
