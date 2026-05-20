import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // scopes: email is requested so we can identify the user
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email and Password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // FR1-11: Mandatory email verification (sent in background without blocking)
      result.user?.sendEmailVerification().catchError((error) {
        print('Error sending verification email: $error');
      });

      // Create a user document in Firestore with ALL required fields
      await _firestore.collection('users').doc(result.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'avatarUrl': '',
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'selectedVibes': [],
        'karmaPoints': 0,
        'isSuperUser': false,
        'isAdmin': false,
        'isPro': false,
        'contributionStreak': 0,
        'badges': [],
        'savedGems': [],
        'chatsStartedToday': 0,
        'lastChatResetDate': null,
        'lastContributionTime': null,
        'acceptsMessages': true,
        'isDndEnabled': false,
        'dndStartHour': 22,
        'dndEndHour': 8,
        'blockedUsers': [],
        'isBanned': false,
      });

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Email and Password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // FR11-6: Check if user is banned
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (userDoc.exists && (userDoc.data()!['isBanned'] == true)) {
        await _auth.signOut();
        throw 'Your account has been suspended. Please contact support.';
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Google Sign-In (FR1-2)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // User cancelled the sign-in
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      // Check that we have the required tokens
      if (googleAuth.idToken == null) {
        throw 'Google Sign-In failed: Could not obtain authentication token. '
            'Please ensure Google Sign-In is enabled in your Firebase console '
            'and that the SHA-1 fingerprint of your app is registered.';
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          // Initialize new Google user in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'fullName': user.displayName ?? 'Explorer',
            'email': user.email ?? '',
            'avatarUrl': user.photoURL ?? '',
            'bio': '',
            'createdAt': FieldValue.serverTimestamp(),
            'selectedVibes': [],
            'karmaPoints': 10, // Bonus for Google sign up
            'isSuperUser': false,
            'isAdmin': false,
            'isPro': false,
            'contributionStreak': 0,
            'badges': [],
            'savedGems': [],
            'reminders': [],
            'interactionHistory': [],
            'chatsStartedToday': 0,
            'lastChatResetDate': null,
            'lastContributionTime': null,
            'acceptsMessages': true,
            'isDndEnabled': false,
            'dndStartHour': 22,
            'dndEndHour': 8,
            'blockedUsers': [],
            'isBanned': false,
          });
        } else {
          // Check if user is banned
          final data = doc.data()!;
          if (data['isBanned'] == true) {
            await _auth.signOut();
            await _googleSignIn.signOut();
            throw 'Your account has been suspended. Please contact support.';
          }
        }
      }
      return userCredential;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed') {
        throw 'Google Sign-In is not configured. Please enable Google Sign-In '
            'in Firebase Console → Authentication → Sign-in method, '
            'add your app\'s SHA-1 fingerprint, and re-download google-services.json.';
      }
      throw 'Google Sign-In failed: ${e.message}';
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Google Sign-In failed. Please try again.';
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Error Mapping Utility
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Error: $code';
    }
  }

  // Delete Account (FR1-12)
  Future<void> deleteAccount(String uid) async {
    try {
      // 1. Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // 2. Delete the Auth account
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'For security, please re-authenticate (Log out and back in) before deleting your account.';
      }
      throw _mapError(e.code);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Get User Data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update User Vibes
  Future<void> updateUserVibes(String uid, List<String> vibes) async {
    await _firestore.collection('users').doc(uid).update({
      'selectedVibes': vibes,
    });
  }

  // FR11-6: Ban a user (admin action)
  Future<void> banUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isBanned': true});
  }

  // FR11-6: Unban a user (admin action)
  Future<void> unbanUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isBanned': false});
  }
}
