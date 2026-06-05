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

        // 🔥 NOVO: Dispara o pré-carregamento de todos os tempos de espera em background.
        // NOTA: Não usamos "await" aqui de propósito! Queremos que corra em segundo plano
        // para que o ecrã principal da app abra instantaneamente sem ficar a aguardar por isto.
        _prefetchAllWaitTimes(stations);

      } catch (_) {}
      _cachedStations = stations;
      return _cachedStations;
    }

    _cachedStations = await local.getStations();
    return _cachedStations;
  }

  Future<void> _prefetchAllWaitTimes(List<Station> stations) async {
    if (generic == null) return;

    // Percorre todas as estações existentes e saca os tempos de espera de cada uma
    for (final station in stations) {
      try {
        final result = await generic!.execute(
          type: GenericOperationType.GetWaitTimes,
          data: station.id,
        );

        if (result != null) {
          final waitTimes = (result as List<dynamic>).cast<Map<String, dynamic>>();
          // Grava silenciosamente no SQLite
          await local.saveWaitTimes(station.id, waitTimes);
        }
      } catch (e) {
        // Se falhar uma estação (ex: timeout ou erro de API), continua para a próxima
        debugPrint('Erro ao pré-carregar tempos para a estação ${station.id}: $e');
      }
    }
    debugPrint(' Sincronização em massa de tempos de espera concluída com sucesso!');
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

  Future<List<Map<String, dynamic>>> getWaitTimes(String stationId) async {
    // 1. Verifica se o telemóvel tem internet
    final isOnline = await connectivity.isConnected();

    if (isOnline && generic != null) {
      try {
        // 2. Se estiver online, vai buscar à API remota
        final result = await generic!.execute(
          type: GenericOperationType.GetWaitTimes,
          data: stationId,
        );

        if (result != null) {
          final waitTimes = (result as List<dynamic>).cast<Map<String, dynamic>>();

          // 3. GRAVA NO SQLITE para ficar guardado para quando ficar offline
          await local.saveWaitTimes(stationId, waitTimes);

          return waitTimes;
        }
      } catch (e) {
        debugPrint('Erro ao buscar tempos online: $e. A tentar ler do banco local...');
      }
    }

    // 4. Se estiver offline (ou se a API falhar), faz o Fallback para o SQLite local
    return await local.getWaitTimes(stationId);
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

    await local.attachIncident(id, report);

    notifyListeners();
  }


  Future<void> insertStation(Station station) async {
    await local.insertStation(station);
  }

  Future<List<Station>> getStationsByName(String name) async {
    return local.getStationsByName(name);
  }



}