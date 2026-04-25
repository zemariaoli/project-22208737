import 'package:flutter/material.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StationDetailPage extends StatelessWidget {
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

  String formatLineName(String lineName) {
    if (lineName.startsWith('Linha ')) {
      return lineName;
    }

    return 'Linha $lineName';
  }

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<MetroRepository>(context, listen: false);
    final station = repository.getStation(stationId);

    if (station == null) {
      return Scaffold(
        key: const Key('detail-screen'),
        appBar: AppBar(
          title: const Text('Detail'),
        ),
        body: const Center(
          child: Text('Estação não encontrada'),
        ),
      );
    }

    return Scaffold(
      key: const Key('detail-screen'),
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 4, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(station.name),
            Text(formatLineName(station.lineName)),
            Text(station.latitude.toString()),
            Text(station.longitude.toString()),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                key: const Key('detail-screen-incidents-list'),
                itemCount: station.reports.length,
                itemBuilder: (context, index) {
                  final report = station.reports[index];

                  final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                      .format(report.timestamp);

                  return Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(formattedDate),
                            Text(' - ${report.type.name.toUpperCase()}'),
                          ],
                        ),

                        if (report.notes != null && report.notes!.isNotEmpty)
                          Text(
                            report.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}