import 'package:cmproject/models/incident_report.dart';

class Station {
  final String id;
  final String name;
  final String lineName;
  final double latitude;
  final double longitude;
  final List<IncidentReport> reports;

  Station({
    required this.id,
    required this.name,
    required this.lineName,
    required this.latitude,
    required this.longitude,
    List<IncidentReport>? reports,
  }) : reports = reports ?? [];

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['stop_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['stop_name'] ?? json['name'] ?? '',
      lineName: json['linha'] ?? json['lineName'] ?? '',
      latitude: double.tryParse(json['stop_lat']?.toString() ?? '') ??
          (json['latitude'] ?? 0).toDouble(),
      longitude: double.tryParse(json['stop_lon']?.toString() ?? '') ??
          (json['longitude'] ?? 0).toDouble(),
    );
  }

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      name: map['name'],
      lineName: map['lineName'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lineName': lineName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}