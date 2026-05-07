import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hidden_gem_model.dart';
import '../models/user_model.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';


class GemsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
  StreamSubscription? _gemsSubscription;
  StreamSubscription? _usersSubscription;
  List<HiddenGem> _gems = [];
  bool _isLoading = true;
  Position? _userLocation;
  Set<String> _superUserIds = {};

  List<HiddenGem> get gems => _gems;
  bool get isLoading => _isLoading;
  Position? get userLocation => _userLocation;

  GemsProvider() {
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

  // Filtered and sorted list for regular users
  List<HiddenGem> get approvedGems {
    final approved = _gems.where((gem) => gem.isApproved).toList();
    approved.sort(_compareDiscoveryPriority);
    return approved;
  }

  bool isSuperUserContributor(String contributorId) => _superUserIds.contains(contributorId);

  List<HiddenGem> superUserRecommendations() {
    return approvedGems.where((gem) => isSuperUserContributor(gem.contributorId)).toList();
  }

  int _compareDiscoveryPriority(HiddenGem a, HiddenGem b) {
    final aIsSuperUser = isSuperUserContributor(a.contributorId);
    final bIsSuperUser = isSuperUserContributor(b.contributorId);

    if (aIsSuperUser != bIsSuperUser) {
      return aIsSuperUser ? -1 : 1;
    }

    if (a.isTrending != b.isTrending) {
      return a.isTrending ? -1 : 1;
    }

    if (_userLocation != null) {
      final distanceA = LocationService.calculateDistance(
        _userLocation!.latitude,
        _userLocation!.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = LocationService.calculateDistance(
        _userLocation!.latitude,
        _userLocation!.longitude,
        b.latitude,
        b.longitude,
      );

      if (distanceA != distanceB) {
        return distanceA.compareTo(distanceB);
      }
    }

    return b.rating.compareTo(a.rating);
  }

  void _initGemsListener() {
    _isLoading = true;
    _gemsSubscription = _firestore.collection('gems').snapshots().listen((snapshot) {
      _gems = snapshot.docs.map((doc) {
        return HiddenGem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Firestore Stream Error: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  void _initSuperUserListener() {
    _usersSubscription = _firestore.collection('users').snapshots().listen((snapshot) {
      _superUserIds = snapshot.docs
          .where((doc) => doc.data()['isSuperUser'] == true)
          .map((doc) => doc.id)
          .toSet();
      notifyListeners();
    }, onError: (error) {
      print('User Stream Error: $error');
    });
  }

  // List for moderators/admins
  List<HiddenGem> get pendingGems => _gems.where((gem) => !gem.isApproved).toList();


  Future<void> approveGem(String gemId, String contributorId) async {
    try {
      // 1. Mark as approved
      await _firestore.collection('gems').doc(gemId).update({'isApproved': true});
      
      // 2. Award Karma to contributor
      await _awardKarmaToUser(contributorId, 50);
    } catch (e) {
      print('Error approving gem: $e');
    }
  }

  Future<void> rejectGem(String gemId) async {
    try {
      await _firestore.collection('gems').doc(gemId).delete();
    } catch (e) {
      print('Error rejecting gem: $e');
    }
  }

  Future<void> _awardKarmaToUser(String userId, int points) async {
    final userDoc = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      if (snapshot.exists) {
        int currentKarma = snapshot.data()?['karmaPoints'] ?? 0;
        int newKarma = currentKarma + points;
        bool shouldPromote = newKarma >= 500;
        
        transaction.update(userDoc, {
          'karmaPoints': newKarma,
          if (shouldPromote) 'isSuperUser': true,
        });
      }
    });
  }

  // Method to add a gem (Phase 4 placeholder)
  Future<void> addGem(HiddenGem gem, UserModel user) async {
    // 1. Spam Prevention: 5-minute cooldown
    if (user.lastContributionTime != null) {
      final diff = DateTime.now().difference(user.lastContributionTime!);
      if (diff.inMinutes < 5) {
        throw Exception('Please wait ${5 - diff.inMinutes} more minutes before sharing another gem.');
      }
    }

    final batch = _firestore.batch();
    
    // 2. Add Gem
    final gemRef = _firestore.collection('gems').doc();
    batch.set(gemRef, {
      ...gem.toMap(),
      'contributorId': user.id,
      'isApproved': false,
    });

    // 3. Update User's last contribution time
    final userRef = _firestore.collection('users').doc(user.id);
    batch.update(userRef, {
      'lastContributionTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

