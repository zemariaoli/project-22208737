import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/list_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String searchStation = '';
  Future<List<Station>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
  }

  List<String> _extractLineNames(String lineName) {
    var cleaned = lineName
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();

    cleaned = cleaned.replaceAll(
      RegExp(r'\bLinha\b', caseSensitive: false),
      '',
    );

    return cleaned
        .split(RegExp(r'\s*(?:,|;|/|\||\be\b)\s*', caseSensitive: false))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_capitalize)
        .toList();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }

  String formatLineName(String lineName) {
    final lines = _extractLineNames(lineName);

    if (lines.isEmpty) {
      return 'Linha desconhecida';
    }

    if (lines.length == 1) {
      return 'Linha ${lines.first}';
    }

    if (lines.length == 2) {
      return 'Linha ${lines[0]} e ${lines[1]}';
    }

    final firstLines = lines.sublist(0, lines.length - 1).join(', ');
    final lastLine = lines.last;

    return 'Linha $firstLines e $lastLine';
  }

  List<Station> _filterStations(List<Station> stations) {
    final query = searchStation.toLowerCase();

    return stations.where((station) {
      final stationName = station.name.toLowerCase();
      final lineName = formatLineName(station.lineName).toLowerCase();

      return stationName.contains(query) || lineName.contains(query);
    }).toList();
  }

  void _navigateToDetail(BuildContext context, Station station) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailPage(
          stationId: station.id,
          stationName: station.name,
          lineName: formatLineName(station.lineName),
          latitude: station.latitude,
          longitude: station.longitude,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchStation = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Pesquisar estação...',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFB71C1C),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE0E0E0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFB71C1C),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 MÉTODO CORRIGIDO: Adicionado o Material wrapper para evitar o erro do splash escondido
  Widget _buildStationTile(BuildContext context, Station station) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(
            color: Color(0xFFB71C1C),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(16), // Acompanha o raio do Container
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: _buildLineAvatar(station),
          title: Text(
            station.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            formatLineName(station.lineName),
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFFB71C1C),
          ),
          onTap: () => _navigateToDetail(context, station),
        ),
      ),
    );
  }

  Widget _buildLineAvatar(Station station) {
    final colors = _lineColors(station.lineName);

    if (colors.length == 1) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: colors.first,
        child: _avatarText(station),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            Row(
              children: colors.map((color) {
                return Expanded(
                  child: Container(color: color),
                );
              }).toList(),
            ),
            Center(
              child: _avatarText(station),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarText(Station station) {
    return Text(
      station.name.isNotEmpty ? station.name[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  List<Color> _lineColors(String lineName) {
    final lines = _extractLineNames(lineName);

    if (lines.isEmpty) {
      return [Colors.blueGrey];
    }

    return lines.map(_colorFromLineName).toList();
  }

  Color _colorFromLineName(String lineName) {
    final normalized = lineName.toLowerCase().trim();

    if (normalized == 'azul') {
      return Colors.blue;
    }

    if (normalized == 'amarela' || normalized == 'amarelo') {
      return Colors.amber;
    }

    if (normalized == 'verde') {
      return Colors.green;
    }

    if (normalized == 'vermelha' || normalized == 'vermelho') {
      return Colors.red;
    }

    return Colors.blueGrey;
  }

  Widget _buildList(List<Station> filteredStations) {
    return ListView.separated(
      key: const Key('list-view'),
      itemCount: filteredStations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        return _buildStationTile(context, filteredStations[index]);
      },
    );
  }

  Widget _buildErrorMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Não foi possível obter as estações de metro. Verifique a conectividade e volte a tentar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('list-screen'),
      appBar: AppBar(
        title: const Text(
          'Estações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEBEE),
              Color(0xFFF8F8F8),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8E0000),
                      Color(0xFFC62828),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rede Metropolitana',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Estações do Metro de Lisboa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Station>>(
                future: _stationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB71C1C),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorMessage();
                  }

                  final stations = snapshot.data ?? [];

                  if (stations.isEmpty) {
                    return _buildErrorMessage();
                  }

                  final filteredStations = _filterStations(stations);

                  if (filteredStations.isEmpty) {
                    return const Center(
                      child: Text('Sem estações disponíveis.'),
                    );
                  }

                  return _buildList(filteredStations);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}