import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationModule {

  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 5), onTimeout: () => throw Exception());
    } catch (_) {
      return null;
    }
  }

  Stream<LocationData> onLocationChanged() {
    return Stream.empty();
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