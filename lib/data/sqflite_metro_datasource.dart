import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteMetroDataSource extends MetroDataSource {
  Database? _db;

  SqfliteMetroDataSource();

  Future<bool> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'metro.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            lineName TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL
          )
        ''');
      },
    );
    return true;
  }

  Database get db {
    if (_db == null) throw Exception('Base de dados não inicializada. Chama init() primeiro.');
    return _db!;
  }

  @override
  Future<List<Station>> getStations() async {
    return getAllStations();
  }

  @override
  Future<List<Station>> getAllStations() async {
    final result = await db.query('stations');
    return result.map((e) => Station.fromMap(e)).toList();
  }


  @override
  Future<void> insertStation(Station station) async {
    await db.insert(
      'stations',
      station.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Station>> getStationsByName(String name) async {
    final result = await db.query('stations');
    final stations = result.map((e) => Station.fromMap(e)).toList();
    final query = name.toLowerCase();
    return stations.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.lineName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Future<Station> getStationDetail(String id) async {
    final result = await db.query(
      'stations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) throw Exception('Estação não encontrada');
    return Station.fromMap(result.first);
  }

  @override
  Future<void> attachIncident(String id, IncidentReport report) async {
    throw UnimplementedError('Incidentes não persistidos na base de dados.');
  }

  Future<void> saveStations(List<Station> stations) async {

    if (_db == null) return;

    await db.delete('stations');
    for (final station in stations) {
      await db.insert(
        'stations',
        station.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}