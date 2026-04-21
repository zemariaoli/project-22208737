import 'package:flutter/material.dart';
import 'package:cmproject/repository/stations_repository.dart';

class StationDetailPage extends StatefulWidget{
  
  final String stationId;
  final String stationName;
  final String lineName;
  
  const StationDetailPage({super.key,
    required this.stationId,
    required this.stationName,
    required this.lineName});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  @override
  Widget build(BuildContext context) {
    final repository = StationsRepository();
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
          title: const Text('Detail')
      ),
    );
  }
}
