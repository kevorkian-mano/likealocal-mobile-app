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
}

class ChatPreview {
  final String id;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String relatedGemName;

  ChatPreview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.relatedGemName,
  });

  static List<ChatPreview> get mockList => [
    ChatPreview(
      id: '1',
      userName: 'Amira Khalil',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
      lastMessage: 'The entrance is right behind the blue door.',
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
      unreadCount: 2,
      relatedGemName: 'The Secret Jazz Garden',
    ),
    ChatPreview(
      id: '2',
      userName: 'Omar Sherif',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150',
      lastMessage: 'Definitely try the stuffed vine leaves!',
      lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
      relatedGemName: 'Tante Amira\'s Kitchen',
    ),
  ];
}
