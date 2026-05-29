import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityModule {

  Future<bool> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> isConnected() async {
    return checkConnectivity();
  }

}