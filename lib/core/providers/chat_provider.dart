import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');

  Future<void> startNewChat(UserModel user, String targetUserId) async {
    // 1. Prevent messaging self
    if (user.id == targetUserId) {
      throw Exception('You cannot message yourself.');
    }

    // 2. Pro Constraints (FR5-3)
    if (!user.isPro && !user.isSuperUser) {
      final now = DateTime.now();
      bool needsReset = user.lastChatResetDate == null || 
          user.lastChatResetDate!.day != now.day ||
          user.lastChatResetDate!.month != now.month ||
          user.lastChatResetDate!.year != now.year;

      int currentChats = needsReset ? 0 : user.chatsStartedToday;

      if (currentChats >= 3) {
        throw Exception('Daily chat limit reached. Upgrade to Pro for unlimited chats!');
      }

      // 3. Increment chat count
      await _firestore.collection('users').doc(user.id).update({
        'chatsStartedToday': currentChats + 1,
        'lastChatResetDate': FieldValue.serverTimestamp(),
      });
    }

    // 4. Create Chat Document (Placeholder for real messaging)
    // In a real system, we would check if a chat already exists between these two.
    print('Starting chat with $targetUserId');
  }
}

