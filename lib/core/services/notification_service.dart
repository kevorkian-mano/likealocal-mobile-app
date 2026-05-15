import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../app_export.dart';

// Top level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        showLocalNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data['gemId'] ?? '',
        );
      }
    });

    // 4. Handle Background Messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Get Initial Message (Deep Linking when app was terminated)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleDeepLink(initialMessage.data);
    }

    // 6. Handle App Opened from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleDeepLink(message.data);
    });
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'likelocal_channel',
      'LikeALocal Notifications',
      channelDescription: 'General notifications for LikeALocal app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      _handleDeepLink({'gemId': response.payload});
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    final gemId = data['gemId'];
    if (gemId != null && gemId.toString().isNotEmpty) {
      NavigatorService.pushNamed(AppRoutes.placeDetailsScreen, arguments: gemId);
    }
  }

  Future<String?> getDeviceToken() async {
    return await _fcm.getToken();
  }

  // FR11-7: Send broadcast notification to all users (using FCM topic)
  Future<void> sendBroadcast(String title, String message) async {
    // In a real production environment, you would call a Cloud Function.
    // For this demonstration, we'll use the FCM topic 'all_users'.
    // Every user should be subscribed to this topic on initialize.
    try {
      await _fcm.subscribeToTopic('all_users');
      
      // Since we don't have a server-side key or service account here,
      // we'll simulate the "backend" by sending a message to Firestore 'broadcasts' collection.
      // A Cloud Function would then trigger on this document to send the real FCM.
      await FirebaseFirestore.instance.collection('broadcasts').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'target': 'all_users',
      });
      print('Broadcast document created in Firestore for Cloud Function trigger.');
    } catch (e) {
      print('Error sending broadcast: $e');
      rethrow;
    }
  }
}
