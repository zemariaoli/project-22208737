import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final MapController _mapController = MapController();
  final LocationModule _locationModule = LocationModule();
  LatLng _currentPosition = const LatLng(38.7369, -9.1427); // Lisboa por defeito
  Future<List<Station>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final position = await _locationModule.getCurrentPosition();
    if (position == null) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_currentPosition, 13);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('map-screen'),
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          final stations = snapshot.data ?? [];

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13,
            ),
            children: [
              // Camada OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pt.ulusofona.deisi.cm.cmproject',
              ),

              // Marker da localização atual
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),

              // Markers das estações
              MarkerLayer(
                markers: stations.map((station) {
                  return Marker(
                    point: LatLng(station.latitude, station.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
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
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),

      // Botão para centrar na localização atual
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}