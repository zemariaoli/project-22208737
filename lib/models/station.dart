import 'dart:core';

import 'incident_report.dart';

class Station {

  final String id;
  final String name;
  final double latitude, longitude;
  final String lineName;
  final List<IncidentReport> reports;


  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.lineName,
    List<IncidentReport>? reports,
  }) : reports = reports ?? [];


  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Station && other.id == id);

  @override
  int get hashCode => id.hashCode;
}