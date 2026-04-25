import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';

class MetroRepository {
  final List<Station> _stations = [];

  MetroRepository();

  List<Station> getAllStations() {
    return _stations;
  }

  List<Station> getStations() {
    return _stations;
  }

  Station? getStation(String id) {
    for (final station in _stations) {
      if (station.id == id) {
        return station;
      }
    }

    return null;
  }

  Station getStationDetail(String id) {
    final station = getStation(id);

    if (station == null) {
      throw Exception('Estação não encontrada');
    }

    return station;
  }

  void attachIncident(String id, IncidentReport report) {
    final station = getStation(id);

    if (station != null) {
      station.reports.add(report);
    }
  }

  void insertStation(Station station) {
    _stations.add(station);
  }

  List<Station> getStationsByName(String name) {
    return _stations.where((station) {
      final query = name.toLowerCase();

      return station.name.toLowerCase().contains(query) ||
          station.lineName.toLowerCase().contains(query);
    }).toList();
  }
}