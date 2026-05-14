import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hidden_gem_model.dart';
import '../models/user_model.dart';
import '../models/reminder_model.dart';
import '../utils/gamification_helper.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

// FR3-6: Pin limits per user tier
const int FREE_USER_PIN_LIMIT = 10;
const int PRO_USER_PIN_LIMIT = 100;

class GemsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
  StreamSubscription? _gemsSubscription;
  StreamSubscription? _usersSubscription;
  List<HiddenGem> _gems = [];
  bool _isLoading = true;
  Position? _userLocation;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  Set<String> _superUserIds = {};

  List<HiddenGem> get gems => _gems;
  bool get isLoading => _isLoading;
  Position? get userLocation => _userLocation;

  GemsProvider() {
    debugPrint('[GemsProvider] Initializing GemsProvider...');
    _initGemsListener();
    _initSuperUserListener();
    updateLocation();
  }

  @override
  void dispose() {
    _gemsSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }

  Future<void> updateLocation() async {
    _userLocation = await LocationService.getCurrentLocation();
    notifyListeners();
  }

  List<HiddenGem> get approvedGems {
    final approved = _gems.where((gem) => gem.status == GemStatus.approved).toList();
    debugPrint('[GemsProvider] Total gems: ${_gems.length}, Approved gems: ${approved.length}');
    if (_gems.isNotEmpty && approved.isEmpty) {
      debugPrint('[GemsProvider] WARNING: No approved gems found. Gem statuses: ${_gems.map((g) => g.status).toSet()}');
    }
    
    // Boosted gems always appear first (FR12-5)
    // Super User gems appear second (FR7-4)
    approved.sort((a, b) {
      if (a.isBoosted && !b.isBoosted) return -1;
      if (!a.isBoosted && b.isBoosted) return 1;

      if (a.contributorIsSuperUser && !b.contributorIsSuperUser) return -1;
      if (!a.contributorIsSuperUser && b.contributorIsSuperUser) return 1;

      if (_userLocation != null) {
        double distA = LocationService.calculateDistance(
          _userLocation!.latitude, _userLocation!.longitude, a.latitude, a.longitude
        );
        double distB = LocationService.calculateDistance(
          _userLocation!.latitude, _userLocation!.longitude, b.latitude, b.longitude
        );
        return distA.compareTo(distB);
      }
      return 0;
    });
    return approved;
  }

  List<HiddenGem> superUserRecommendations() {
    return approvedGems.where((gem) => gem.contributorIsSuperUser).toList();
  }

  /// Get the nearest approved gem from current user location
  HiddenGem? getNearestGem() {
    if (approvedGems.isEmpty || _userLocation == null) return null;
    
    HiddenGem? nearest;
    double minDistance = double.infinity;
    
    for (final gem in approvedGems) {
      final distance = LocationService.calculateDistance(
        _userLocation!.latitude, _userLocation!.longitude,
        gem.latitude, gem.longitude
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = gem;
      }
    }
    
    return nearest;
  }

  /// Format distance for display (e.g., "250m", "2.5km")
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  void _initGemsListener() {
    _isLoading = true;
    _gemsSubscription = _firestore.collection('gems')
      .where('status', whereIn: ['approved', 'pending'])
      .snapshots().listen((snapshot) {
      debugPrint('[GemsProvider] Loaded ${snapshot.docs.length} gems from Firestore');
      _gems = snapshot.docs.map((doc) {
        final map = doc.data();
        final gem = HiddenGem.fromMap(map, doc.id);
        final isSuper = (map['contributorIsSuperUser'] ?? false) || _superUserIds.contains(map['contributorId']);
        return gem.copyWith(contributorIsSuperUser: isSuper);
      }).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('[GemsProvider] Firestore Stream Error: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  void _initSuperUserListener() {
    _usersSubscription = _firestore.collection('users')
      .where('isSuperUser', isEqualTo: true)
      .snapshots()
      .listen((snapshot) {
        _superUserIds = snapshot.docs.map((d) => d.id).toSet();
        // Update gems list to reflect current super-user set
        _gems = _gems.map((g) => g.copyWith(contributorIsSuperUser: _superUserIds.contains(g.contributorId))).toList();
        notifyListeners();
      }, onError: (error) {
        debugPrint('SuperUser listener error: $error');
      });
  }

  List<HiddenGem> get pendingGems => _gems.where((gem) => gem.status == GemStatus.pending).toList();

  Future<void> approveGem(String gemId, String contributorId) async {
    try {
      await _firestore.collection('gems').doc(gemId).update({'status': 'approved'});
      await _awardKarmaAndCheckBadges(contributorId, 50);
    } catch (e) {
      debugPrint('Error approving gem: $e');
    }
  }

  Future<void> rejectGem(String gemId) async {
    try {
      await _firestore.collection('gems').doc(gemId).update({'status': 'rejected'});
    } catch (e) {
      debugPrint('Error rejecting gem: $e');
    }
  }

  Future<void> _awardKarmaAndCheckBadges(String userId, int points) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final userSnap = await userDoc.get();
    if (userSnap.exists) {
      final user = UserModel.fromMap(userSnap.data()!, userSnap.id);
      final gamification = GamificationHelper.updateStreakAndBadges(user);
      
      await userDoc.update({
        'karmaPoints': FieldValue.increment(points),
        'contributionStreak': gamification['streak'],
        'badges': gamification['badges'],
        'isSuperUser': (user.karmaPoints + points) >= 500,
      });
    }
  }

  Future<void> addGem(HiddenGem gem, UserModel user) async {
    // Spam Prevention
    if (user.lastContributionTime != null) {
      final diff = DateTime.now().difference(user.lastContributionTime!);
      if (diff.inMinutes < 5) {
        throw Exception('Slow down! Wait ${5 - diff.inMinutes} mins between posts.');
      }
    }

    final batch = _firestore.batch();
    final gemRef = _firestore.collection('gems').doc();
    
    // FR4-11: Immediate approval for Super Users
    final finalStatus = user.isSuperUser ? GemStatus.approved : GemStatus.pending;
    
    // Create new gem object to inject finalStatus, id, and contributorIsSuperUser
    final finalGem = HiddenGem(
      id: gemRef.id,
      name: gem.name,
      description: gem.description,
      category: gem.category,
      vibe: gem.vibe,
      rating: gem.rating,
      imageUrl: gem.imageUrl,
      latitude: gem.latitude,
      longitude: gem.longitude,
      localsTip: gem.localsTip,
      recommendedDishes: gem.recommendedDishes,
      isPremium: gem.isPremium,
      isTrending: gem.isTrending,
      isVerified: gem.isVerified,
      contributorId: user.id,
      status: finalStatus,
      contributorIsSuperUser: user.isSuperUser,
    );

    batch.set(gemRef, finalGem.toMap());

    // Update User Stats (FR4-14)
    final gamification = GamificationHelper.updateStreakAndBadges(user);
    batch.update(_firestore.collection('users').doc(user.id), {
      'lastContributionTime': FieldValue.serverTimestamp(),
      'contributionStreak': gamification['streak'],
      'badges': gamification['badges'],
      'karmaPoints': FieldValue.increment(10),
    });

    _isSyncing = true;
    notifyListeners();
    try {
      await batch.commit();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // FR4-8: Edit Place
  Future<void> updateGem(String id, Map<String, dynamic> updates) async {
    await _firestore.collection('gems').doc(id).update(updates);
  }

  // FR4-9: Delete Place
  Future<void> deleteGem(String id) async {
    await _firestore.collection('gems').doc(id).delete();
  }

  // FR3-2: Track view counts
  Future<void> incrementViews(String gemId) async {
    try {
      await _firestore.collection('gems').doc(gemId).update({
        'views': FieldValue.increment(1)
      });
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  // FR3-3: Bookmark favorite places with FR3-6 pin limit enforcement
  Future<void> toggleSaveGem(String userId, String gemId, bool isCurrentlySaved) async {
    _isSyncing = true;
    notifyListeners();
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final userSnap = await userDoc.get();
      final user = UserModel.fromMap(userSnap.data()!, userSnap.id);
      
      // FR3-6: Check pin limit enforcement for free users
      if (!isCurrentlySaved) {
        // User is trying to add a new pin
        final pinLimit = user.isPro ? PRO_USER_PIN_LIMIT : FREE_USER_PIN_LIMIT;
        final currentPinCount = user.savedGems.length;
        
        if (currentPinCount >= pinLimit) {
          // FR3-6: Notify user they've reached limit
          throw Exception(
            'Pin limit reached! ${user.isPro ? "Pro" : "Free"} users can save up to $pinLimit places. '
            '${user.isPro ? "" : "Upgrade to Pro to save more!"}'
          );
        }
      }
      
      final gemDoc = _firestore.collection('gems').doc(gemId);
      
      if (isCurrentlySaved) {
        await userDoc.update({
          'savedGems': FieldValue.arrayRemove([gemId])
        });
        await gemDoc.update({
          'saves': FieldValue.increment(-1)
        });
      } else {
        // FR10-1: Enforcement (3 pins for Free users)
        final userSnap = await userDoc.get();
        final user = UserModel.fromMap(userSnap.data()!, userSnap.id);
        
        if (!user.isPro && !user.isSuperUser && user.savedGems.length >= 3) {
          throw Exception('LIMIT_REACHED');
        }

        await userDoc.update({
          'savedGems': FieldValue.arrayUnion([gemId])
        });
        await gemDoc.update({
          'saves': FieldValue.increment(1)
        });
      }
    } catch (e) {
      debugPrint('Error toggling save gem: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Analytics for Admin Dashboard
  Map<String, double> get categoryDistribution {
    if (_gems.isEmpty) return {};
    final counts = <String, int>{};
    for (var gem in _gems) {
      counts[gem.category] = (counts[gem.category] ?? 0) + 1;
    }
    final total = _gems.length;
    return counts.map((key, value) => MapEntry(key, value / total));
  }

  List<double> get discoveryVelocity {
    // Last 7 days submission counts
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final velocity = List.filled(7, 0.0);

    for (var gem in _gems) {
      if (gem.createdAt == null) continue;
      for (int i = 0; i < 7; i++) {
        if (gem.createdAt!.day == last7Days[i].day && 
            gem.createdAt!.month == last7Days[i].month) {
          velocity[i]++;
        }
      }
    }
    return velocity;
  }

  // FR3-8: Add a review to a gem (stored in gems/{gemId}/reviews sub-collection)
  Future<void> addReview({
    required String gemId,
    required String userId,
    required String userName,
    String avatarUrl = '',
    required double rating,
    required String text,
  }) async {
    final reviewRef = _firestore.collection('gems').doc(gemId).collection('reviews').doc();
    await reviewRef.set({
      'gemId': gemId,
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Update overall gem rating (running average approximation)
    final allReviews = await _firestore.collection('gems').doc(gemId).collection('reviews').get();
    final avgRating = allReviews.docs.fold<double>(0, (sum, d) => sum + (d['rating'] as num).toDouble()) / allReviews.docs.length;
    await _firestore.collection('gems').doc(gemId).update({'rating': double.parse(avgRating.toStringAsFixed(1))});
  }

  // FR3-9: Edit an existing review (only allowed for review owner)
  Future<void> editReview(String gemId, String reviewId, {double? rating, String? text}) async {
    final updates = <String, dynamic>{};
    if (rating != null) updates['rating'] = rating;
    if (text != null) updates['text'] = text;
    if (updates.isEmpty) return;
    await _firestore.collection('gems').doc(gemId).collection('reviews').doc(reviewId).update(updates);
  }

  // FR3-9: Delete a review (owner or admin)
  Future<void> deleteReview(String gemId, String reviewId) async {
    await _firestore.collection('gems').doc(gemId).collection('reviews').doc(reviewId).delete();
  }

  // FR3-8/10: Stream all reviews for a gem
  Stream<QuerySnapshot> getReviewsStream(String gemId) {
    return _firestore
        .collection('gems')
        .doc(gemId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // FR3-7: Create a location-based reminder for a place
  Future<String> createReminder({
    required String userId,
    required HiddenGem gem,
    double radiusMeters = 500.0,
  }) async {
    try {
      final remindersRef = _firestore.collection('reminders');
      final docRef = remindersRef.doc();
      
      final reminder = Reminder(
        id: docRef.id,
        userId: userId,
        gemId: gem.id,
        gemName: gem.name,
        latitude: gem.latitude,
        longitude: gem.longitude,
        radiusMeters: radiusMeters,
        message: 'You are near "${gem.name}"! 📍',
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      await docRef.set(reminder.toMap());
      debugPrint('[GemsProvider] Reminder created for ${gem.name}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating reminder: $e');
      rethrow;
    }
  }

  // FR3-7: Get user's active reminders
  Stream<QuerySnapshot> getUserRemindersStream(String userId) {
    return _firestore
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // FR3-7: Disable a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).update({
        'isActive': false,
      });
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      rethrow;
    }
  }

  // FR3-7: Check if user is near a reminder location (should be called periodically by location service)
  Future<List<Reminder>> checkNearbyReminders(String userId, Position userLocation) async {
    try {
      final remindersSnap = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      final nearbyReminders = <Reminder>[];
      
      for (final doc in remindersSnap.docs) {
        final reminder = Reminder.fromMap(doc.data(), doc.id);
        final distance = LocationService.calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          reminder.latitude,
          reminder.longitude,
        );
        
        // If within geofence radius and not already triggered
        if ((distance * 1000) < reminder.radiusMeters && reminder.triggeredAt == null) {
          nearbyReminders.add(reminder);
          // Mark as triggered
          await _firestore.collection('reminders').doc(reminder.id).update({
            'triggeredAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      return nearbyReminders;
    } catch (e) {
      debugPrint('Error checking reminders: $e');
      return [];
    }
  }

  // FR12-5: Boost a gem for 24 hours (SuperUser action)
  Future<void> boostGem(String gemId) async {
    final boostedUntil = DateTime.now().add(const Duration(hours: 24));
    await _firestore.collection('gems').doc(gemId).update({
      'isBoosted': true,
      'boostedUntil': Timestamp.fromDate(boostedUntil),
    });
  }

  // FR12-5: Expire boosts that have passed their time
  Future<void> expireBoosts() async {
    final now = Timestamp.now();
    final boosted = await _firestore.collection('gems')
        .where('isBoosted', isEqualTo: true)
        .where('boostedUntil', isLessThan: now)
        .get();
    for (var doc in boosted.docs) {
      await doc.reference.update({'isBoosted': false, 'boostedUntil': null});
    }
  }
}



