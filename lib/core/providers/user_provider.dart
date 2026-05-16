import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../models/hidden_gem_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getUserData(firebaseUser.uid);

        // FR11-7: Update FCM Token for notifications
        try {
          NotificationService().getDeviceToken().then((token) async {
            if (token != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(firebaseUser.uid)
                  .update({'fcmToken': token});
            }
          });
        } catch (e) {
          debugPrint('Error updating FCM token: $e');
        }
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Updates any subset of the user's profile fields in Firestore.
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    List<String>? selectedVibes,
    bool? acceptsMessages,
    bool? isDndEnabled,
    int? dndStartHour,
    int? dndEndHour,
  }) async {
    if (_user == null) return;

    final Map<String, dynamic> updates = {};
    if (fullName != null) updates['fullName'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (selectedVibes != null) updates['selectedVibes'] = selectedVibes;
    if (acceptsMessages != null) updates['acceptsMessages'] = acceptsMessages;
    if (isDndEnabled != null) updates['isDndEnabled'] = isDndEnabled;
    if (dndStartHour != null) updates['dndStartHour'] = dndStartHour;
    if (dndEndHour != null) updates['dndEndHour'] = dndEndHour;

    if (updates.isEmpty) return;

    try {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(_user!.id).update(updates);

      // Refresh local state immediately using copyWith
      _user = _user!.copyWith(
        fullName: fullName,
        avatarUrl: avatarUrl,
        bio: bio,
        selectedVibes: selectedVibes,
        acceptsMessages: acceptsMessages,
        isDndEnabled: isDndEnabled,
        dndStartHour: dndStartHour,
        dndEndHour: dndEndHour,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Locally update saved gems immediately for UI responsiveness
  void updateSavedGemsLocally(String gemId, bool isRemoving) {
    if (_user == null) return;
    final newSavedGems = List<String>.from(_user!.savedGems);
    if (isRemoving) {
      newSavedGems.remove(gemId);
    } else {
      newSavedGems.add(gemId);
    }
    _user = _user!.copyWith(savedGems: newSavedGems);
    notifyListeners();
  }

  // FR6-1: Track user interactions for personalization
  Future<void> trackInteraction(String category, String vibe) async {
    if (_user == null) return;

    final interaction = {
      'category': category,
      'vibe': vibe,
      'timestamp': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(_user!.id).update({
        'interactionHistory': FieldValue.arrayUnion([interaction]),
      });

      _user = _user!.copyWith(
        interactionHistory: [..._user!.interactionHistory, interaction],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error tracking interaction: $e');
    }
  }

  Future<void> addKarmaPoints(int points) async {
    if (_user == null) return;

    final newPoints = _user!.karmaPoints + points;
    bool shouldPromote = newPoints >= 500 && !_user!.isSuperUser;

    try {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(_user!.id).update({
        'karmaPoints': newPoints,
        if (shouldPromote) 'isSuperUser': true,
      });

      // Local refresh
      _user = _user!.copyWith(
        karmaPoints: newPoints,
        isSuperUser: shouldPromote ? true : null,
      );
      notifyListeners();
    } catch (e) {
      print('Error updating karma: $e');
    }
  }

  Future<void> purchasePro() async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(_user!.id).update({'isPro': true});
      _user = _user!.copyWith(isPro: true);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (_user == null) return;
    try {
      await _authService.deleteAccount(_user!.id);
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // FR5-5: Block a user — adds to blockedUsers list
  Future<void> blockUser(String targetUserId) async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(_user!.id).update({
        'blockedUsers': FieldValue.arrayUnion([targetUserId]),
      });
      _user = _user!.copyWith(
        blockedUsers: [..._user!.blockedUsers, targetUserId],
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // FR11-6: Admin ban a user
  Future<void> banUser(String targetUserId) async {
    if (_user == null || !_user!.isAdmin) return;
    await _authService.banUser(targetUserId);
  }

  // FR11-6: Admin unban a user
  Future<void> unbanUser(String targetUserId) async {
    if (_user == null || !_user!.isAdmin) return;
    await _authService.unbanUser(targetUserId);
  }

  // FR11-7: Broadcast notification (admin only)
  Future<void> broadcastNotification(String title, String message) async {
    if (_user == null || !_user!.isAdmin) return;

    // 1. Persist in Firestore for in-app banner
    await FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    ).collection('notifications').add({
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'createdBy': _user!.id,
    });

    // 2. Send via FCM Topic (simulation for real backend connection)
    await NotificationService().sendBroadcast(title, message);
  }

  // FR11-7: Stream of active admin notifications
  Stream<List<Map<String, dynamic>>> getActiveNotifications() {
    return FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'default',
        )
        .collection('notifications')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // FR3-7/FR10-1: Toggle Location Reminder with limits
  Future<void> toggleReminder(String gemId) async {
    if (_user == null) return;

    final isRemoving = _user!.reminders.contains(gemId);

    if (!isRemoving) {
      // Enforce limit: 1 reminder for Free users
      if (!_user!.isPro && !_user!.isSuperUser && _user!.reminders.isNotEmpty) {
        throw Exception('LIMIT_REACHED');
      }
    }

    try {
      final docRef = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(_user!.id);

      if (isRemoving) {
        await docRef.update({
          'reminders': FieldValue.arrayRemove([gemId]),
        });
        _user = _user!.copyWith(
          reminders: _user!.reminders.where((id) => id != gemId).toList(),
        );
      } else {
        await docRef.update({
          'reminders': FieldValue.arrayUnion([gemId]),
        });
        _user = _user!.copyWith(reminders: [..._user!.reminders, gemId]);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // FR7-2: Calculate Reputation Score dynamically based on live user gems
  double calculateReputationScore(List<HiddenGem> userGems) {
    if (_user == null) return 0.0;
    
    int approvedGemsCount = 0;
    int totalViews = 0;
    int totalSaves = 0;

    for (final gem in userGems) {
      if (gem.status == GemStatus.approved) {
        approvedGemsCount += 1;
        totalViews += gem.views;
        totalSaves += gem.saves;
      }
    }

    // Reputation Score = (Approved Gems * 50) + (Total Views * 1) + (Total Saves * 5)
    return (approvedGemsCount * 50.0) + (totalViews * 1.0) + (totalSaves * 5.0);
  }
}
