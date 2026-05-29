import 'package:cmproject/connectivity_module.dart';
import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/data/sqflite_metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/cupertino.dart';

import 'generic_data_source.dart';

class MetroRepository extends ChangeNotifier {
  final MetroDataSource remote;
  final SqfliteMetroDataSource local;
  final ConnectivityModule connectivity;
  final GenericDataSource? generic;

  final Map<String, List<IncidentReport>> _incidents = {};
  List<Station> _cachedStations = [];
  List<Station> get cachedStations => _cachedStations;

  MetroRepository({
    required this.remote,
    required this.local,
    required this.connectivity,
    this.generic,
  });

  Future<List<Station>> getStations() async {
    final isOnline = await connectivity.isConnected();

    if (isOnline) {
      final stations = await remote.getStations();
      // Tenta guardar localmente mas não falha se não conseguir
      try {
        await local.saveStations(stations);
      } catch (_) {}
      _cachedStations = stations;
      return _cachedStations;
    }

    _cachedStations = await local.getStations();
    return _cachedStations;
  }

  Future<List<Station>> getAllStations() async {
    return local.getAllStations();
  }

  Future<Station?> getStation(String id) async {
    final cached = _cachedStations.where((s) => s.id == id).firstOrNull;
    if (cached != null) return cached;

    try {
      return await local.getStationDetail(id);
    } catch (_) {
      return null;
    }
  }

  Future<Station> getStationDetail(String id) async {
    return local.getStationDetail(id);
  }

  List<IncidentReport> getIncidents(String stationId) {
    return _incidents[stationId] ?? [];
  }

  void attachIncident(String id, IncidentReport report) {
    _incidents[id] = [...(_incidents[id] ?? []), report];
    notifyListeners();
  }

  Future<void> insertStation(Station station) async {
    await local.insertStation(station);
  }

  Future<List<Station>> getStationsByName(String name) async {
    return local.getStationsByName(name);
  }
}