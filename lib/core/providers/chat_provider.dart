import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../services/notification_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );

  Future<void> startNewChat(
    UserModel sender,
    String targetUserId,
    String gemName,
  ) async {
    // 1. Prevent messaging self
    if (sender.id == targetUserId) {
      throw Exception('You cannot message yourself.');
    }

    // 2. Block check (FR5-5)
    if (sender.blockedUsers.contains(targetUserId)) {
      throw Exception(
        'You have blocked this user. Unblock them to send messages.',
      );
    }

    // 3. Pro Constraints (FR5-3)
    if (!sender.isPro && !sender.isSuperUser) {
      final now = DateTime.now();
      bool needsReset =
          sender.lastChatResetDate == null ||
          sender.lastChatResetDate!.day != now.day ||
          sender.lastChatResetDate!.month != now.month ||
          sender.lastChatResetDate!.year != now.year;

      int currentChats = needsReset ? 0 : sender.chatsStartedToday;

      if (currentChats >= 10) {
        throw Exception(
          'Daily chat limit reached. Upgrade to Pro for unlimited chats!',
        );
      }

      // Increment chat count locally/remotely
      await _firestore.collection('users').doc(sender.id).update({
        'chatsStartedToday': currentChats + 1,
        'lastChatResetDate': FieldValue.serverTimestamp(),
      });
    }

    // 3. Recipient Settings Check (FR5-2, FR5-3)
    final recipientDoc = await _firestore
        .collection('users')
        .doc(targetUserId)
        .get();
    if (recipientDoc.exists) {
      final recipient = UserModel.fromMap(
        recipientDoc.data()!,
        recipientDoc.id,
      );

      if (!recipient.acceptsMessages) {
        throw Exception(
          '${recipient.fullName} has opted out of receiving messages.',
        );
      }

      if (recipient.isDndEnabled) {
        final now = DateTime.now().hour;
        // Simple circular check
        bool inDnd = false;
        if (recipient.dndStartHour > recipient.dndEndHour) {
          inDnd = now >= recipient.dndStartHour || now < recipient.dndEndHour;
        } else {
          inDnd = now >= recipient.dndStartHour && now < recipient.dndEndHour;
        }

        if (inDnd) {
          throw Exception(
            '${recipient.fullName} is currently in DND mode. Try again later.',
          );
        }
      }
    }

    // 4. Create Chat Document if not exists
    final chatId = _getChatId(sender.id, targetUserId);
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [sender.id, targetUserId],
        'participantNames': {
          sender.id: sender.fullName,
          targetUserId: recipientDoc.exists
              ? recipientDoc.data()!['fullName']
              : 'Unknown',
        },
        'participantAvatars': {
          sender.id: sender.avatarUrl,
          targetUserId: recipientDoc.exists
              ? recipientDoc.data()!['avatarUrl']
              : '',
        },
        'lastMessage': 'Chat started about $gemName',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'relatedGemName': gemName,
        'isPriority': sender.isPro || sender.isSuperUser, // FR5-3
      });
    }
  }

  String _getChatId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final batch = _firestore.batch();
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    batch.set(messageRef, {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('chats').doc(chatId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<List<ChatMessage>> getMessages(String chatId, String currentUserId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatMessage.fromMap(doc.data(), doc.id, currentUserId),
              )
              .toList(),
        );
  }

  Stream<List<ChatPreview>> getMyChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatPreview.fromMap(doc.data(), doc.id, userId))
              .toList(),
        );
  }

  // FR8-3: Listen for new messages across all chats to show notifications
  void startListeningForNewMessages(String userId) {
    _firestore
        .collectionGroup('messages')
        .where('timestamp', isGreaterThan: Timestamp.now())
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data()!;
              final senderId = data['senderId'];

              if (senderId != userId) {
                // Check if this message belongs to a chat the user is part of
                // For simplicity in demo, we'll just check if the message is new
                NotificationService().showLocalNotification(
                  id: change.doc.id.hashCode,
                  title: "New Message 💬",
                  body: data['text'] ?? "You have a new message",
                  payload: change.doc.reference.parent.parent?.id, // chatId
                );
              }
            }
          }
        });
  }
}
