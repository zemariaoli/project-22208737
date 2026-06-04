import 'dart:convert';
import 'package:cmproject/data/generic_data_source.dart';
import 'package:cmproject/http/http_client.dart';

class HttpGenericDataSource extends GenericDataSource {
  static const String _baseUrl =
      'https://api.metrolisboa.pt:8243/estadoServicoML/1.0.1';

  final HttpClient _client = HttpClient();

  @override
  Future<dynamic> execute({
    required GenericOperationType type,
    dynamic data,
  }) async {
    switch (type) {
      case GenericOperationType.GetNames:
        return null;

      case GenericOperationType.GetWaitTimes:
        final stationId = data as String?;
        if (stationId == null) return null;

        final response = await _client.get(
          url: '$_baseUrl/tempoEspera/Estacao/$stationId',
        );

        if (response.statusCode != 200) return null;

        final body = jsonDecode(response.body);
        return body['resposta'] ?? body;
    }
  }
}