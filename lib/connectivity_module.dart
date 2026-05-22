import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityModule {
  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}