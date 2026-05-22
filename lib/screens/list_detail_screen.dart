import 'package:flutter/material.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/location_module.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StationDetailPage extends StatefulWidget {
  final String stationId;
  final String stationName;
  final String lineName;
  final double latitude;
  final double longitude;

  const StationDetailPage({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.lineName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  Future<Station?> _stationFuture = Future.value(null);
  Future<List<Map<String, dynamic>>> _waitTimesFuture = Future.value([]);
  double? _distanceMeters;
  final _locationModule = LocationModule();

  @override
  void initState() {
    super.initState();
    final repository = context.read<MetroRepository>();
    _stationFuture = repository.getStation(widget.stationId);
    //_waitTimesFuture = repository.getWaitTimes(widget.stationId);
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final position = await _locationModule.getCurrentPosition();
    if (position == null) return;

    final distance = _locationModule.distanceTo(
      fromLat: position.latitude,
      fromLon: position.longitude,
      toLat: widget.latitude,
      toLon: widget.longitude,
    );

    setState(() => _distanceMeters = distance);
  }

  String formatLineName(String lineName) {
    if (lineName.startsWith('Linha ')) return lineName;
    return 'Linha $lineName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('detail-screen'),
      appBar: AppBar(
        title: Text(widget.stationName),
      ),
      body: FutureBuilder<Station?>(
        future: _stationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Estação não encontrada'));
          }

          final station = snapshot.data!;

          final avgRating = station.reports.isEmpty
              ? null
              : station.reports.map((r) => r.rate).reduce((a, b) => a + b) /
              station.reports.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ESTAÇÃO
                const Text(
                  'Estação:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Text(station.id),
                          Text(station.name),
                          Text(formatLineName(station.lineName)),
                          Text(
                            _distanceMeters != null
                                ? '${_distanceMeters!.toStringAsFixed(0)} metros até a esta estação'
                                : 'A calcular distância...',
                          ),
                          Text(
                            'Média de incidentes: ${avgRating != null ? avgRating.toStringAsFixed(1) : 'Indisponível'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // TEMPOS DE ESPERA
                const Text(
                  'Tempos de espera:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _waitTimesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final waitTimes = snapshot.data ?? [];

                    if (waitTimes.isEmpty) {
                      return const Text(
                        'Sem tempos de espera disponíveis.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    return Column(
                      children: waitTimes.map((wt) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(wt['destination'] ?? wt['cais'] ?? ''),
                              Text('${wt['time'] ?? wt['tempoEspera']}s'),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // INCIDENTES
                const Text(
                  'Incidentes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (station.reports.isEmpty)
                  const Text(
                    'Sem incidentes registados.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ListView.builder(
                    key: const Key('detail-screen-incidents-list'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: station.reports.length,
                    itemBuilder: (context, index) {
                      final report = station.reports[index];
                      final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                          .format(report.timestamp);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(formattedDate),
                                Text(' - ${report.type.name.toUpperCase()}'),
                              ],
                            ),
                            if (report.notes != null &&
                                report.notes!.isNotEmpty)
                              Text(
                                report.notes!,
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}