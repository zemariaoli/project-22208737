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

  List<String> _extractLineNames(String lineName) {
    final line = lineName
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('Linha', '')
        .replaceAll('linha', '')
        .toLowerCase();

    final lineMap = <String, String>{
      'azul': 'Azul',
      'amarela': 'Amarela',
      'verde': 'Verde',
      'vermelha': 'Vermelha',
    };

    final foundLines = <MapEntry<int, String>>[];

    lineMap.forEach((key, value) {
      final index = line.indexOf(key);

      if (index != -1) {
        foundLines.add(MapEntry(index, value));
      }
    });

    foundLines.sort((a, b) => a.key.compareTo(b.key));

    return foundLines.map((entry) => entry.value).toList();
  }

  List<Station> _filterStations(List<Station> stations) {
    final query = searchStation.toLowerCase();

    return stations.where((station) {
      return station.name.toLowerCase().contains(query) ||
          formatLineName(station.lineName).toLowerCase().contains(query);
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
        onChanged: (value) => setState(() => searchStation = value),
        decoration: InputDecoration(
          hintText: 'Pesquisar estação...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildStationTile(BuildContext context, Station station) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildLineAvatar(station),
        title: Text(
          station.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(formatLineName(station.lineName)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToDetail(context, station),
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
      station.name[0].toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  List<Color> _lineColors(String lineName) {
    final lines = _extractLineNames(lineName);

    final colors = <Color>[];

    for (final line in lines) {
      if (line == 'Azul') {
        colors.add(Colors.blue);
      } else if (line == 'Amarela') {
        colors.add(Colors.amber);
      } else if (line == 'Verde') {
        colors.add(Colors.green);
      } else if (line == 'Vermelha') {
        colors.add(Colors.red);
      }
    }

    if (colors.isEmpty) {
      colors.add(Colors.blueGrey);
    }

    return colors;
  }

  Widget _buildList(List<Station> filteredStations) {
    return ListView.separated(
      key: const Key('list-view'),
      itemCount: filteredStations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _buildStationTile(context, filteredStations[index]),
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
              'Não foi possível obter as estações de metro.\nVerifique a conectividade e volte a tentar.',
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<Station>>(
                future: _stationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorMessage();
                  }

                  final stations = snapshot.data ?? [];

                  if (stations.isEmpty) {
                    return _buildErrorMessage();
                  }

                  final filtered = _filterStations(stations);

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Sem estações disponíveis.'),
                    );
                  }

                  return _buildList(filtered);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}