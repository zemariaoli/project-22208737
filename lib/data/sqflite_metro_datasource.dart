import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteMetroDataSource extends MetroDataSource {
  final Database db;

  SqfliteMetroDataSource(this.db);

  @override
  Future<List<Station>> getStations() async {
    final result = await db.query('stations');
    return result.map((e) => Station.fromMap(e)).toList();
  }

  @override
  Future<List<Station>> getAllStations() => getStations();

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

    if (result.isEmpty) {
      throw Exception('Estação não encontrada');
    }

    return Station.fromMap(result.first);
  }

  @override
  Future<void> attachIncident(String id, IncidentReport report) async {
    // Incidentes são guardados em memória (não persistidos na DB)
    // Se quiseres persistir, precisas de criar uma tabela de incidentes
    throw UnimplementedError('Incidentes não persistidos na base de dados.');
  }

  // Método auxiliar para guardar lista completa (usado pelo repositório)
  Future<void> saveStations(List<Station> stations) async {
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