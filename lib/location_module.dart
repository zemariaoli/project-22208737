import 'package:geolocator/geolocator.dart';

class LocationModule {
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition();
  }

  double distanceTo({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
  }) {
    return Geolocator.distanceBetween(fromLat, fromLon, toLat, toLon);
  }
}