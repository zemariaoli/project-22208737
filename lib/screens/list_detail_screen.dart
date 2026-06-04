import 'package:flutter/material.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/incident_report.dart';
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

  @override
  void initState() {
    super.initState();
    final repository = context.read<MetroRepository>();
    _stationFuture = repository.getStation(widget.stationId);
    _waitTimesFuture = repository.getWaitTimes(widget.stationId);
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final locationModule = context.read<LocationModule>();
    final position = await locationModule.getCurrentPosition();
    if (position == null) return;

    final distance = locationModule.distanceTo(
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStationCard(Station station, double? avgRating) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.train, color: Colors.blueGrey, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatLineName(station.lineName),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(
                  Icons.location_on,
                  _distanceMeters != null
                      ? '${_distanceMeters!.toStringAsFixed(0)} m'
                      : '...',
                  'Distância',
                ),
                _buildInfoChip(
                  Icons.star,
                  avgRating != null ? avgRating.toStringAsFixed(1) : 'N/A',
                  'Média',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Color _waitTimeColor(dynamic time) {
    final seconds = int.tryParse(time.toString()) ?? 0;
    if (seconds <= 60) return Colors.green.shade600;
    if (seconds <= 180) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Widget _buildWaitTimesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _waitTimesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final waitTimes = snapshot.data ?? [];

        if (waitTimes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Sem tempos de espera disponíveis.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Agrupa por cais
        final Map<String, List<Map<String, dynamic>>> byCais = {};
        for (final wt in waitTimes) {
          final cais = wt['cais'] ?? 'Desconhecido';
          byCais.putIfAbsent(cais, () => []);

          if (wt['comboio'] != null && wt['tempoChegada1'] != null) {
            byCais[cais]!.add({
              'comboio': wt['comboio'],
              'tempo': wt['tempoChegada1'],
            });
          }
          if (wt['comboio2'] != null && wt['tempoChegada2'] != null) {
            byCais[cais]!.add({
              'comboio': wt['comboio2'],
              'tempo': wt['tempoChegada2'],
            });
          }
          if (wt['comboio3'] != null && wt['tempoChegada3'] != null) {
            byCais[cais]!.add({
              'comboio': wt['comboio3'],
              'tempo': wt['tempoChegada3'],
            });
          }

          // Ordena por tempo
          byCais[cais]!.sort((a, b) {
            final ta = int.tryParse(a['tempo'].toString()) ?? 0;
            final tb = int.tryParse(b['tempo'].toString()) ?? 0;
            return ta.compareTo(tb);
          });
        }

        return Column(
          children: byCais.entries.map((entry) {
            final cais = entry.key;
            final trains = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header do cais
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.train, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Cais $cais',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Comboios do cais
                  ...trains.asMap().entries.map((trainEntry) {
                    final index = trainEntry.key;
                    final train = trainEntry.value;
                    final seconds =
                        int.tryParse(train['tempo'].toString()) ?? 0;
                    final minutes = seconds ~/ 60;
                    final secs = seconds % 60;
                    final timeLabel =
                    minutes > 0 ? '${minutes}m ${secs}s' : '${secs}s';

                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.directions_subway,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Comboio ${train['comboio']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _waitTimeColor(seconds),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              timeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildIncidentTile(IncidentReport report) {
    final formattedDate =
    DateFormat('dd/MM/yyyy HH:mm').format(report.timestamp);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading:
        const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: Row(
          children: [
            Text(formattedDate),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report.type.name.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
        subtitle: report.notes != null && report.notes!.isNotEmpty
            ? Text(report.notes!)
            : null,
      ),
    );
  }

  Widget _buildIncidentsSection(List<IncidentReport> reports) {
    return ListView.builder(
      key: const Key('detail-screen-incidents-list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) => _buildIncidentTile(reports[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<MetroRepository>();

    return Scaffold(
      key: const Key('detail-screen'),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.stationName),
        elevation: 0,
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
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
          final reportsFromStation = station.reports;
          final reportsFromSession =
          repository.getIncidents(widget.stationId);
          final reports = [
            ...reportsFromStation,
            ...reportsFromSession
                .where((r) => !reportsFromStation.contains(r)),
          ];

          final avgRating = reports.isEmpty
              ? null
              : reports.map((r) => r.rate).reduce((a, b) => a + b) /
              reports.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStationCard(station, avgRating),
                const SizedBox(height: 24),
                _buildSectionTitle('Tempos de espera'),
                _buildWaitTimesSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('Incidentes'),
                _buildIncidentsSection(reports),
              ],
            ),
          );
        },
      ),
    );
  }
}