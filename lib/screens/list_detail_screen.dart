import 'package:flutter/material.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/incident_report.dart';


class StationDetailPage extends StatefulWidget{
  
  final String stationId;
  final String stationName;
  final String lineName;
  final double latitude, longitude;
  final List<IncidentReport> reports;
  
  const StationDetailPage({super.key,
    required this.stationId,
    required this.stationName,
    required this.lineName,
    required this.latitude,
    required this.longitude,
    List<IncidentReport>? reports,
  }): reports = reports ?? const [];

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  @override
  Widget build(BuildContext context) {
    final repository = MetroRepository();
    final station = repository.getStation(
      widget.stationId,
    );

    if (station == null) {
      return Scaffold(
        key: const Key('detail-screen'),
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(
          child: Text('Estação não encontrada'),
        ),
      );
    }

    return Scaffold(
      key: const Key('detail-screen'),
      appBar: AppBar(
          title: const Text('Detail'),
      ), body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(station.name),
          Text(station.lineName),
          Text(station.latitude.toString()),
          Text(station.longitude.toString()),
        ],
      ),
    );
  }
}
