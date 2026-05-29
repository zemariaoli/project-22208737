import 'dart:convert';
import 'package:cmproject/data/metro_datasource.dart';
import 'package:cmproject/http/http_client.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';

class HttpMetroDataSource extends MetroDataSource {
  static const String _baseUrl =
      'https://api.metrolisboa.pt:8243/estadoServicoML/1.0.1';

  final HttpClient _client = HttpClient();

  @override
  Future<List<Station>> getStations() async {
    return getAllStations();
  }

  @override
  Future<List<Station>> getAllStations() async {
    final response = await _client.get(url: '$_baseUrl/infoEstacao/todos');

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar estações: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['resposta'] ?? body;
    return data.map<Station>((e) => Station.fromJson(e)).toList();
  }

  @override
  Future<List<Station>> getStationsByName(String name) async =>
      throw UnimplementedError('Use o repositório local para pesquisar.');

  @override
  Future<Station> getStationDetail(String id) async =>
      throw UnimplementedError('Use o repositório local para detalhe.');

  @override
  Future<void> attachIncident(String id, IncidentReport report) async =>
      throw UnimplementedError('Use o repositório local para incidentes.');

  @override
  Future<void> insertStation(Station station) async =>
      throw UnimplementedError('Use o repositório local para inserir.');
}