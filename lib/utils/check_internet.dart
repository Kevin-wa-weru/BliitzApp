// ignore_for_file: unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';

import 'dart:io';

class ConnectivityHelper {
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // First, check network status (WiFi, Mobile, etc.)
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Then, check real internet access
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }

    return false;
  }
}
