import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/location_module.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/list_detail_screen.dart';

/// Ecrã do mapa interativo com os marcadores das estações do Metro de Lisboa.
/// Suporta geolocalização em tempo real e navegação para o detalhe de cada estação.
class MapScreen extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  // ─── Estado ───────────────────────────────────────────────────────────────

  /// Controlador do mapa para animações de câmara.
  GoogleMapController? _mapController;

  /// Posição atual do utilizador (Lisboa por defeito).
  LatLng _currentPosition = const LatLng(38.7369, -9.1427);

  /// Future para carregar as estações da API / base de dados.
  Future<List<Station>>? _stationsFuture;

  // ─── Ciclo de vida ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Carrega as estações uma única vez ao inicializar o ecrã
    _stationsFuture = context.read<MetroRepository>().getStations();
    // Tenta obter a localização atual do utilizador
    _loadLocation();
  }

  // ─── Lógica de localização ────────────────────────────────────────────────

  /// Obtém a posição atual do utilizador e centra o mapa nessa posição.
  Future<void> _loadLocation() async {
    final locationModule = context.read<LocationModule>();
    final position = await locationModule.getCurrentPosition();
    if (position == null) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // Anima a câmara para a posição atual
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentPosition),
    );
  }

  // ─── Widgets auxiliares ───────────────────────────────────────────────────

  /// Cria os marcadores vermelhos para cada estação.
  /// Ao clicar num marcador, navega para o ecrã de detalhe da estação.
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

  /// Navega para o ecrã de detalhe da estação.
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

  /// Botões flutuantes de controlo do mapa (zoom + / zoom - / localização).
  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botão de zoom in
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          backgroundColor: Colors.blueGrey.shade800,
          onPressed: () =>
              _mapController?.animateCamera(CameraUpdate.zoomIn()),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 8),
        // Botão de zoom out
        FloatingActionButton.small(
          heroTag: 'zoom_out',
          backgroundColor: Colors.blueGrey.shade800,
          onPressed: () =>
              _mapController?.animateCamera(CameraUpdate.zoomOut()),
          child: const Icon(Icons.remove, color: Colors.white),
        ),
        const SizedBox(height: 8),
        // Botão para centrar na localização atual
        FloatingActionButton(
          heroTag: 'my_location',
          backgroundColor: Colors.blueGrey.shade800,
          onPressed: _loadLocation,
          tooltip: 'Centrar na minha localização',
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ],
    );
  }

  // ─── Build principal ──────────────────────────────────────────────────────

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
          // A carregar as estações
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
            );
          }

          final stations = snapshot.data ?? [];

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 13,
            ),
            markers: _buildMarkers(stations),
            myLocationEnabled: true,       // Mostra o ponto azul da localização atual
            myLocationButtonEnabled: false, // Usa o FAB personalizado em vez do botão nativo
            zoomControlsEnabled: false,     // Usa os FABs personalizados em vez dos controlos nativos
            onMapCreated: (controller) => _mapController = controller,
          );
        },
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }
}