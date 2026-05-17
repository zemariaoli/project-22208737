import 'package:cmproject/connectivity_module.dart';
import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/data/sqflite_metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';

class MetroRepository {
  final MetroDataSource remote;
  final SqfliteMetroDataSource local;
  final ConnectivityModule connectivity;

  MetroRepository({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  Future<List<Station>> getStations() async {
    final isOnline = await connectivity.isConnected();

    if (isOnline) {
      final stations = await remote.getStations();
      await local.saveStations(stations);
      return stations;
    }

    return local.getStations();
  }

  Future<List<Station>> getAllStations() async {
    return local.getAllStations();
  }

  Future<Station?> getStation(String id) async {
    try {
      return await local.getStationDetail(id);
    } catch (_) {
      return null;
    }
  }

  Future<Station> getStationDetail(String id) async {
    return local.getStationDetail(id);
  }

  Future<void> attachIncident(String id, IncidentReport report) async {
    await local.attachIncident(id, report);
  }

  Future<void> insertStation(Station station) async {
    await local.insertStation(station);
  }

  Future<List<Station>> getStationsByName(String name) async {
    return local.getStationsByName(name);
  }
}