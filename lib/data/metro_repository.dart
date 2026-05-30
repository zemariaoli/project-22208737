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
    try {
      // Vai sempre ao local para trazer a station com reports
      return await local.getStationDetail(id);
    } catch (_) {
      // Fallback para a cache se o local falhar
      return _cachedStations.where((s) => s.id == id).firstOrNull;
    }
  }

  Future<Station> getStationDetail(String id) async {
    return local.getStationDetail(id);
  }

  List<IncidentReport> getIncidents(String stationId) {
    // Primeiro verifica o map interno (incidentes adicionados na sessão)
    final fromMap = _incidents[stationId] ?? [];

    // Depois verifica a station em cache (incidentes que vieram do datasource)
    final fromCache = _cachedStations
        .where((s) => s.id == stationId)
        .firstOrNull?.reports ?? [];

    // Junta os dois sem duplicados
    final all = [...fromCache];
    for (final r in fromMap) {
      if (!all.contains(r)) all.add(r);
    }
    return all;
  }

  Future<void> attachIncident(String id, IncidentReport report) async {

    _incidents[id] = [...(_incidents[id] ?? []), report];

    final index = _cachedStations.indexWhere((s) => s.id == id);
    if (index != -1) {
      _cachedStations[index].reports.add(report);
    }

    await local.attachIncident(id, report);;

    notifyListeners();
  }


  Future<void> insertStation(Station station) async {
    await local.insertStation(station);
  }

  Future<List<Station>> getStationsByName(String name) async {
    return local.getStationsByName(name);
  }
}