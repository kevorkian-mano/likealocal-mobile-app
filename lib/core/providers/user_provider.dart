import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

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

  Future<void> addKarmaPoints(int points) async {
    if (_user == null) return;
    
    final newPoints = _user!.karmaPoints + points;
    bool shouldPromote = newPoints >= 500 && !_user!.isSuperUser;

    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.id).update({
        'karmaPoints': newPoints,
        if (shouldPromote) 'isSuperUser': true,
      });
      
      // Local refresh
      _user = UserModel(
        id: _user!.id,
        fullName: _user!.fullName,
        email: _user!.email,
        avatarUrl: _user!.avatarUrl,
        bio: _user!.bio,
        selectedVibes: _user!.selectedVibes,
        karmaPoints: newPoints,
        isSuperUser: shouldPromote ? true : _user!.isSuperUser,
        isAdmin: _user!.isAdmin,
        isPro: _user!.isPro,
      );
      notifyListeners();
    } catch (e) {
      print('Error updating karma: $e');
    }
  }

  Future<void> purchasePro() async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.id).update({
        'isPro': true,
      });
      _user = UserModel(
        id: _user!.id,
        fullName: _user!.fullName,
        email: _user!.email,
        avatarUrl: _user!.avatarUrl,
        bio: _user!.bio,
        selectedVibes: _user!.selectedVibes,
        karmaPoints: _user!.karmaPoints,
        isSuperUser: _user!.isSuperUser,
        isAdmin: _user!.isAdmin,
        isPro: true,
      );
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
}
