import 'dart:convert';
import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Implementação local do MetroDataSource usando SQLite (via sqflite).
/// Gere as tabelas de estações, incidentes e tempos de espera.
/// Protegida contra uso em testes (onde o SQLite nativo não está disponível).
class SqfliteMetroDataSource extends MetroDataSource {
  // ─── Base de dados ────────────────────────────────────────────────────────

  /// Instância da base de dados SQLite (null até init() ser chamado).
  Database? _db;

  SqfliteMetroDataSource();

  // ─── Inicialização ────────────────────────────────────────────────────────

  /// Abre (ou cria) a base de dados SQLite.
  /// Deve ser chamado antes de qualquer outra operação.
  /// Devolve true em caso de sucesso, false em caso de falha (ex: testes).
  Future<bool> init() async {
    try {
      _db = await openDatabase(
        join(await getDatabasesPath(), 'metro.db'),
        version: 3,
        onCreate: (db, version) async {
          // Tabela de estações
          await db.execute('''
            CREATE TABLE stations (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              lineName TEXT NOT NULL,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL
            )
          ''');

          // Tabela de incidentes (relacionada com stations)
          await db.execute('''
            CREATE TABLE incidents (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              station_id TEXT NOT NULL,
              timestamp TEXT NOT NULL,
              rate INTEGER NOT NULL,
              notes TEXT,
              type TEXT NOT NULL,
              danger INTEGER NOT NULL,
              FOREIGN KEY (station_id) REFERENCES stations (id) ON DELETE CASCADE
            )
          ''');

          // Tabela de tempos de espera (JSON serializado por estação)
          await db.execute('''
            CREATE TABLE wait_times (
              station_id TEXT PRIMARY KEY,
              json_data TEXT NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Migração v1 → v2: adiciona tabela de incidentes
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE incidents (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                station_id TEXT NOT NULL,
                timestamp TEXT NOT NULL,
                rate INTEGER NOT NULL,
                notes TEXT, 
                type TEXT NOT NULL,
                danger INTEGER NOT NULL
                FOREIGN KEY (station_id) REFERENCES stations (id) ON DELETE CASCADE
              )
            ''');
          }
          // Migração v2 → v3: adiciona tabela de tempos de espera
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE wait_times (
                station_id TEXT PRIMARY KEY,
                json_data TEXT NOT NULL
              )
            ''');
          }
        },
      );
      return true;
    } catch (_) {
      // Falha silenciosa em ambiente de teste (SQLite nativo indisponível)
      return false;
    }
  }

  /// Getter protegido da DB — lança exceção se init() não foi chamado.
  Database get db {
    if (_db == null) {
      throw Exception('Base de dados não inicializada. Chama init() primeiro.');
    }
    return _db!;
  }

  // ─── Estações ─────────────────────────────────────────────────────────────

  @override
  Future<List<Station>> getStations() async => getAllStations();

  @override
  Future<List<Station>> getAllStations() async {
    if (_db == null) return []; // Proteção para testes
    final result = await _db!.query('stations');
    return result.map((e) => Station.fromMap(e)).toList();
  }

  @override
  Future<void> insertStation(Station station) async {
    if (_db == null) return; // Proteção para testes
    await _db!.insert(
      'stations',
      station.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Station>> getStationsByName(String name) async {
    if (_db == null) return []; // Proteção para testes
    final result = await _db!.query('stations');
    final stations = result.map((e) => Station.fromMap(e)).toList();
    final query = name.toLowerCase();
    return stations.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.lineName.toLowerCase().contains(query);
    }).toList();
  }

  /// Devolve os detalhes de uma estação, incluindo os seus incidentes persistidos.
  @override
  Future<Station> getStationDetail(String id) async {
    if (_db == null) throw Exception('Estação não encontrada');

    final result = await _db!.query(
      'stations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) throw Exception('Estação não encontrada');

    final station = Station.fromMap(result.first);

    // Carrega os incidentes persistidos desta estação
    final incidentResult = await _db!.query(
      'incidents',
      where: 'station_id = ?',
      whereArgs: [id],
    );

    final localReports = incidentResult.map((e) {
      return IncidentReport(
        timestamp: DateTime.parse(e['timestamp'] as String),
        rate: e['rate'] as int,
        notes: e['notes'] as String?,
        type: IncidentType.values.byName(e['type'] as String),
        danger: (e['danger'] as int) == 1
      );
    }).toList();

    station.reports.addAll(localReports);
    return station;
  }

  /// Guarda a lista completa de estações (apaga as anteriores).
  Future<void> saveStations(List<Station> stations) async {
    if (_db == null) return; // Proteção para testes
    await _db!.delete('stations');
    for (final station in stations) {
      await _db!.insert(
        'stations',
        station.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ─── Incidentes ───────────────────────────────────────────────────────────

  /// Persiste um incidente na tabela de incidents.
  @override
  Future<void> attachIncident(String id, IncidentReport report) async {
    if (_db == null) return; // Proteção para testes
    await _db!.insert(
      'incidents',
      {
        'station_id': id,
        'timestamp': report.timestamp.toIso8601String(),
        'rate': report.rate,
        'notes': report.notes,
        'type': report.type.name,
        'danger': report.danger ? 1 : 0,
      },
    );
  }

  // ─── Tempos de espera ─────────────────────────────────────────────────────

  /// Guarda os tempos de espera de uma estação como JSON na DB.
  /// Usa REPLACE para atualizar se já existir um registo para essa estação.
  Future<void> saveWaitTimes(
      String stationId, List<Map<String, dynamic>> waitTimes) async {
    if (_db == null) return; // Proteção para testes

    await _db!.insert(
      'wait_times',
      {
        'station_id': stationId,
        'json_data': jsonEncode(waitTimes),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lê os tempos de espera de uma estação da DB local.
  /// Devolve lista vazia se não houver dados guardados.
  Future<List<Map<String, dynamic>>> getWaitTimes(String stationId) async {
    if (_db == null) return []; // Proteção para testes

    final result = await _db!.query(
      'wait_times',
      where: 'station_id = ?',
      whereArgs: [stationId],
    );

    if (result.isEmpty) return [];

    final List<dynamic> decoded =
    jsonDecode(result.first['json_data'] as String);
    return decoded.cast<Map<String, dynamic>>();
  }
}