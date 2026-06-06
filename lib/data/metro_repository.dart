import 'package:cmproject/connectivity_module.dart';
import 'package:cmproject/data/generic_data_source.dart';
import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/data/sqflite_metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/foundation.dart';

/// Repositório central da aplicação.
/// Coordena as fontes de dados remota (API) e local (SQLite),
/// gere a cache em memória e notifica os listeners quando há alterações.
class MetroRepository extends ChangeNotifier {
  final MetroDataSource remote;
  final SqfliteMetroDataSource local;
  final ConnectivityModule connectivity;
  final GenericDataSource? generic;

  List<Station> _cachedStations = [];

  List<Station> get cachedStations => _cachedStations;

  MetroRepository({
    required this.remote,
    required this.local,
    required this.connectivity,
    this.generic,
  });

  // ─── Estações ─────────────────────────────────────────────────────────────

  Future<List<Station>> getStations() async {
    final isOnline = await connectivity.isConnected();

    if (isOnline) {
      final stations = await remote.getStations();

      try {
        await local.saveStations(stations);
        _prefetchAllWaitTimes(stations);
      } catch (e) {
        debugPrint('Erro ao guardar estações localmente: $e');
      }

      _cachedStations = stations;
      return _cachedStations;
    }

    _cachedStations = await local.getStations();
    return _cachedStations;
  }

  Future<void> _prefetchAllWaitTimes(List<Station> stations) async {
    if (generic == null) return;

    for (final station in stations) {
      try {
        final result = await generic!.execute(
          type: GenericOperationType.GetWaitTimes,
          data: station.id,
        );

        if (result != null) {
          final waitTimes =
          (result as List<dynamic>).cast<Map<String, dynamic>>();

          await local.saveWaitTimes(station.id, waitTimes);
        }
      } catch (e) {
        debugPrint('Erro ao pré-carregar tempos para ${station.id}: $e');
      }
    }

    debugPrint('Sincronização de tempos de espera concluída.');
  }

  Future<List<Station>> getAllStations() async {
    return local.getAllStations();
  }

  Future<Station?> getStation(String id) async {
    try {
      return await local.getStationDetail(id);
    } catch (_) {
      for (final station in _cachedStations) {
        if (station.id == id) {
          return station;
        }
      }

      return null;
    }
  }

  Future<Station> getStationDetail(String id) async {
    return local.getStationDetail(id);
  }

  Future<void> insertStation(Station station) async {
    await local.insertStation(station);
  }

  Future<List<Station>> getStationsByName(String name) async {
    return local.getStationsByName(name);
  }

  // ─── Tempos de espera ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWaitTimes(String stationId) async {
    final isOnline = await connectivity.isConnected();

    if (isOnline && generic != null) {
      try {
        final result = await generic!.execute(
          type: GenericOperationType.GetWaitTimes,
          data: stationId,
        );

        if (result != null) {
          final waitTimes =
          (result as List<dynamic>).cast<Map<String, dynamic>>();

          await local.saveWaitTimes(stationId, waitTimes);

          return waitTimes;
        }
      } catch (e) {
        debugPrint('Erro ao buscar tempos online: $e. A usar dados locais...');
      }
    }

    return local.getWaitTimes(stationId);
  }

  // ─── Incidentes ───────────────────────────────────────────────────────────

  List<IncidentReport> getIncidents(String stationId) {
    for (final station in _cachedStations) {
      if (station.id == stationId) {
        return station.reports;
      }
    }

    return [];
  }

  Future<void> attachIncident(String id, IncidentReport report) async {
    var savedLocally = false;

    try {
      await local.attachIncident(id, report);
      savedLocally = true;
    } catch (e) {
      debugPrint('Erro ao guardar incidente localmente: $e');
    }

    final index = _cachedStations.indexWhere((station) => station.id == id);

    if (index != -1) {
      if (savedLocally) {
        try {
          final updatedStation = await local.getStationDetail(id);
          _cachedStations[index] = updatedStation;
        } catch (e) {
          debugPrint('Erro ao atualizar estação pela DB: $e');
          _addIncidentToCacheIfMissing(id, report);
        }
      } else {
        _addIncidentToCacheIfMissing(id, report);
      }
    }

    notifyListeners();
  }

  void _addIncidentToCacheIfMissing(String stationId, IncidentReport report) {
    final index = _cachedStations.indexWhere((station) => station.id == stationId);

    if (index == -1) return;

    final alreadyExists = _cachedStations[index].reports.any(
          (existingReport) => _sameIncident(existingReport, report),
    );

    if (!alreadyExists) {
      _cachedStations[index].reports.add(report);
    }
  }

  bool _sameIncident(IncidentReport a, IncidentReport b) {
    return a.timestamp == b.timestamp &&
        a.type == b.type &&
        a.rate == b.rate &&
        a.notes == b.notes;
  }
}