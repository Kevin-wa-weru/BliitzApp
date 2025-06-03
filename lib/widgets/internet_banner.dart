import 'dart:async';
import 'package:bliitz/main.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetNotifier {
  static final InternetNotifier _instance = InternetNotifier._internal();
  factory InternetNotifier() => _instance;

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSnackBarVisible = false;

  InternetNotifier._internal();

  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected =
          results.any((result) => result != ConnectivityResult.none);

      if (!isConnected && !_isSnackBarVisible) {
        _isSnackBarVisible = true;
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text('No internet connection'),
            backgroundColor: const Color(0xE601DE27).withOpacity(0.8),
            duration:
                const Duration(days: 1), // Persist until manually dismissed
          ),
        );
      } else if (isConnected && _isSnackBarVisible) {
        scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        _isSnackBarVisible = false;
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
