import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }
}
