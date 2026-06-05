import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/location_module.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/list_detail_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(38.7369, -9.1427);
  Future<List<Station>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final locationModule = context.read<LocationModule>();
    final position = await locationModule.getCurrentPosition();
    if (position == null) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentPosition),
    );
  }

  Set<Marker> _buildMarkers(List<Station> stations) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: 'Linha ${station.lineName}',
        ),
        onTap: () => _navigateToDetail(station),
      );
    }).toSet();
  }

  void _navigateToDetail(Station station) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationDetailPage(
          stationId: station.id,
          stationName: station.name,
          lineName: station.lineName,
          latitude: station.latitude,
          longitude: station.longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('map-screen'),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Mapa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB71C1C),
              ),
            );
          }

          final stations = snapshot.data ?? [];

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 13,
            ),
            markers: _buildMarkers(stations),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            backgroundColor: Colors.blueGrey.shade800,
            onPressed: () => _mapController?.animateCamera(
              CameraUpdate.zoomIn(),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            backgroundColor: Colors.blueGrey.shade800,
            onPressed: () => _mapController?.animateCamera(
              CameraUpdate.zoomOut(),
            ),
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: Colors.blueGrey.shade800,
            onPressed: _loadLocation,
            tooltip: 'Centrar na minha localização',
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}