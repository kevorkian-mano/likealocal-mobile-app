// File generated manually from google-services.json and GoogleService-Info.plist
// DO NOT EDIT - regenerate using FlutterFire CLI if project changes

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android (from google-services.json) ─────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiuAfbWT_8iOJrZHfiQc3Lc-vDg9sw4o8',
    appId: '1:505356860527:android:8216d4da958f0d8b96a19a',
    messagingSenderId: '505356860527',
    projectId: 'software-mobile-project',
    storageBucket: 'software-mobile-project.firebasestorage.app',
  );

  // ── iOS (from GoogleService-Info.plist) ──────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnIHTzHlJeXeGW4WH-BhMRZi34YuSGzto',
    appId: '1:505356860527:ios:d5490cc452c0552796a19a',
    messagingSenderId: '505356860527',
    projectId: 'software-mobile-project',
    storageBucket: 'software-mobile-project.firebasestorage.app',
    iosBundleId: 'com.example.likelocal',
  );

  // ── Web (same project, using Android API key) ────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiuAfbWT_8iOJrZHfiQc3Lc-vDg9sw4o8',
    appId: '1:505356860527:android:8216d4da958f0d8b96a19a',
    messagingSenderId: '505356860527',
    projectId: 'software-mobile-project',
    storageBucket: 'software-mobile-project.firebasestorage.app',
    authDomain: 'software-mobile-project.firebaseapp.com',
  );
}
