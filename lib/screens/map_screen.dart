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
  late LocationModule _locationModule;

  @override
  void initState() {
    super.initState();
    _locationModule = context.read<LocationModule>();
    _stationsFuture = context.read<MetroRepository>().getStations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('map-screen'),
      appBar: AppBar(title: const Text('Mapa')),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          final stations = snapshot.data ?? [];

          final markers = stations.map((station) {
            return Marker(
              markerId: MarkerId(station.id),
              position: LatLng(station.latitude, station.longitude),
              infoWindow: InfoWindow(title: station.name),
              onTap: () {
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
              },
            );
          }).toSet();

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 13,
            ),
            markers: markers,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}