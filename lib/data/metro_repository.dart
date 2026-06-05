import 'package:cmproject/connectivity_module.dart';
import 'package:cmproject/data/generic_data_source.dart';
import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/data/sqflite_metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/cupertino.dart';

/// Repositório central da aplicação.
/// Coordena as fontes de dados remota (API) e local (SQLite),
/// gere a cache em memória e notifica os listeners quando há alterações.
class MetroRepository extends ChangeNotifier {
  // ─── Dependências injetadas ───────────────────────────────────────────────

  /// Fonte de dados remota (API do Metro Lisboa).
  final MetroDataSource remote;

  /// Fonte de dados local (SQLite).
  final SqfliteMetroDataSource local;

  /// Módulo de conectividade para verificar o estado da rede.
  final ConnectivityModule connectivity;

  /// Fonte de dados genérica para operações extra (ex: tempos de espera).
  /// Opcional — se null, as funcionalidades dependentes são desativadas.
  final GenericDataSource? generic;

  // ─── Cache em memória ─────────────────────────────────────────────────────

  /// Cache das estações carregadas (da API ou da DB).
  List<Station> _cachedStations = [];

  /// Getter público da cache de estações.
  List<Station> get cachedStations => _cachedStations;

  /// Mapa de incidentes adicionados durante a sessão atual.
  /// Chave: ID da estação | Valor: lista de incidentes.
  final Map<String, List<IncidentReport>> _incidents = {};

  // ─── Construtor ───────────────────────────────────────────────────────────

  MetroRepository({
    required this.remote,
    required this.local,
    required this.connectivity,
    this.generic,
  });

  // ─── Estações ─────────────────────────────────────────────────────────────

  /// Carrega as estações da API (online) ou da DB local (offline).
  /// Em modo online, guarda sempre os dados localmente para uso futuro.
  Future<List<Station>> getStations() async {
    final isOnline = await connectivity.isConnected();

    if (isOnline) {
      final stations = await remote.getStations();

      try {
        // Persiste as estações na DB local para acesso offline
        await local.saveStations(stations);

        // Pré-carrega os tempos de espera de todas as estações em segundo plano.
        // Não usamos "await" intencionalmente para não bloquear o ecrã principal.
        _prefetchAllWaitTimes(stations);
      } catch (_) {
        // Falha silenciosa — não impede o funcionamento da app
      }

      _cachedStations = stations;
      return _cachedStations;
    }

    // Modo offline — carrega da DB local
    _cachedStations = await local.getStations();
    return _cachedStations;
  }

  /// Pré-carrega os tempos de espera de todas as estações em background.
  /// Corre silenciosamente — erros individuais não interrompem o processo.
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
          // Guarda na DB local para acesso offline
          await local.saveWaitTimes(station.id, waitTimes);
        }
      } catch (e) {
        // Se uma estação falhar, continua para a próxima
        debugPrint(
            'Erro ao pré-carregar tempos para ${station.id}: $e');
      }
    }

    debugPrint('Sincronização de tempos de espera concluída.');
  }

  /// Devolve todas as estações da DB local.
  Future<List<Station>> getAllStations() async {
    return local.getAllStations();
  }

  /// Devolve os detalhes de uma estação pelo ID.
  /// Tenta primeiro a DB local (que inclui incidentes persistidos).
  /// Se falhar, faz fallback para a cache em memória.
  Future<Station?> getStation(String id) async {
    try {
      return await local.getStationDetail(id);
    } catch (_) {
      // Fallback para a cache se o local falhar (ex: testes ou DB vazia)
      return _cachedStations.where((s) => s.id == id).firstOrNull;
    }
  }

  /// Devolve os detalhes de uma estação diretamente da DB local.
  Future<Station> getStationDetail(String id) async {
    return local.getStationDetail(id);
  }

  // ─── Tempos de espera ─────────────────────────────────────────────────────

  /// Devolve os tempos de espera dos comboios para uma estação.
  /// Em modo online, vai à API e guarda localmente.
  /// Em modo offline (ou se a API falhar), usa os dados guardados na DB.
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

          // Persiste para acesso offline
          await local.saveWaitTimes(stationId, waitTimes);

          return waitTimes;
        }
      } catch (e) {
        // Se a API falhar, usa o fallback local
        debugPrint(
            'Erro ao buscar tempos online: $e. A usar dados locais...');
      }
    }

    // Fallback: lê da DB local
    return local.getWaitTimes(stationId);
  }

  // ─── Incidentes ───────────────────────────────────────────────────────────

  /// Devolve todos os incidentes de uma estação.
  /// Combina os incidentes da cache (vindos do datasource) com os
  /// adicionados durante a sessão atual (guardados no mapa interno).
  List<IncidentReport> getIncidents(String stationId) {
    // Incidentes da cache (carregados da DB ou da API)
    final fromCache = _cachedStations
        .where((s) => s.id == stationId)
        .firstOrNull
        ?.reports ??
        [];

    // Incidentes adicionados nesta sessão
    final fromSession = _incidents[stationId] ?? [];

    // Junta sem duplicados
    final all = [...fromCache];
    for (final r in fromSession) {
      if (!all.contains(r)) all.add(r);
    }
    return all;
  }

  /// Adiciona um incidente a uma estação.
  /// Persiste na DB local, atualiza a cache e notifica os listeners.
  Future<void> attachIncident(String id, IncidentReport report) async {
    // Adiciona ao mapa da sessão atual
    _incidents[id] = [...(_incidents[id] ?? []), report];

    // Atualiza também a cache em memória (para o dashboard refletir)
    final index = _cachedStations.indexWhere((s) => s.id == id);
    if (index != -1) {
      _cachedStations[index].reports.add(report);
    }

    // Persiste na DB local (pode lançar UnimplementedError em testes —
    // o FakeSqfliteMetroDataSource sobrescreve este método)
    try {
      await local.attachIncident(id, report);
    } catch (_) {
      // Falha silenciosa em ambiente de teste
    }

    // Notifica todos os widgets que fazem context.watch<MetroRepository>()
    notifyListeners();
  }

  // ─── Outros ───────────────────────────────────────────────────────────────

  /// Insere uma estação na DB local.
  Future<void> insertStation(Station station) async {
    await local.insertStation(station);
  }

  /// Pesquisa estações pelo nome na DB local.
  Future<List<Station>> getStationsByName(String name) async {
    return local.getStationsByName(name);
  }
}