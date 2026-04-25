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

  @override
  Widget build(BuildContext context) {
    final repository = context.read<MetroRepository>();
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
            Text(station.lineName),
            Text(station.latitude.toString()),
            Text(station.longitude.toString()),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                key: const Key('detail-screen-incidents-list'),
                itemCount: station.reports.length,
                itemBuilder: (context, index) {
                  final report = station.reports[index];

                  return Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat('dd/MM/yyyy HH:mm').format(report.timestamp)} - ${report.type.name}',
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