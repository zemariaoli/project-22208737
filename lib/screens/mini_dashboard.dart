import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';


class MiniDashboard extends StatefulWidget{
  const MiniDashboard({super.key});

  @override
  State<MiniDashboard> createState() => _MiniDashboardScreenState();

}

class _MiniDashboardScreenState  extends State<MiniDashboard>{

  Future<List<Station>>? _stationsFuture;

  static const List<String> _metroLineOrder = [
    'Azul',
    'Amarela',
    'Verde',
    'Vermelha',
  ];

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
  }


  @override
  Widget build(BuildContext context) {

    final repository = context.read<MetroRepository>();

    return Scaffold(
        body: FutureBuilder<List<Station>>(
            future: _stationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) return _buildError();

              final stations = repository.cachedStations.isNotEmpty
                  ? repository.cachedStations
                  : snapshot.data ?? [];

              final totalStations = stations.length;

              final lineCount = _getLineCounts(stations).length;

              return Column(
                children: [

                  const SizedBox(height: 100),

                  Center(
                    child: Text(
                      'Mini dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                    ),
                  ),

                  const SizedBox(height: 350),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                        Text(
                          textAlign: TextAlign.center,
                          'E:$totalStations',
                           // textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.green,
                              fontSize: 30
                          ),
                        ),

                        const SizedBox(width: 40) ,

                        Text(
                          'L:$lineCount',
                          style: TextStyle(
                            color: Colors.blue,
                              fontSize: 30
                          ),
                        )
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ), child: Text(
                      'OK',
                      style: TextStyle(fontSize: 16),
                    )
                  )
                ],
              );
            },
        ),
    );
  }


  Map<String, int> _getLineCounts(List<Station> stations) {
    final counts = <String, int>{
      for (final line in _metroLineOrder) line: 0,
    };

    for (final station in stations) {
      final stationLines = _extractLineNames(station.lineName);

      for (final line in stationLines) {
        counts[line] = (counts[line] ?? 0) + 1;
      }
    }

    counts.removeWhere((line, count) => count == 0);

    return counts;
  }


  String? _normaliseLineName(String value) {
    final normalized = value
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'\bLinha\b', caseSensitive: false), '')
        .trim()
        .toLowerCase();

    switch (normalized) {
      case 'azul':
        return 'Azul';
      case 'amarela':
      case 'amarelo':
        return 'Amarela';
      case 'verde':
        return 'Verde';
      case 'vermelha':
      case 'vermelho':
        return 'Vermelha';
      default:
        return null;
    }
  }


  List<String> _extractLineNames(String rawLineName) {
    final cleaned = rawLineName
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'\bLinha\b', caseSensitive: false), '')
        .trim();

    return cleaned
        .split(RegExp(r'\s*,\s*|\s+e\s+'))
        .map(_normaliseLineName)
        .whereType<String>()
        .toSet()
        .toList();
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Não foi possível carregar os dados.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }


}