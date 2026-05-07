import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Check if any of the results indicate a connection
      _isOnline = results.any((result) => result != ConnectivityResult.none);
      notifyListeners();
    });
  }
}
