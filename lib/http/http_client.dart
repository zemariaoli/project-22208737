import 'dart:io' as io;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:cmproject/http/token_manager.dart';

class HttpClient {
  final _tokenManager = TokenManager();

  late final HttpWithMiddleware client;

  HttpClient() {
    client = HttpWithMiddleware.build(
      middlewares: [
        HttpLogger(logLevel: LogLevel.BASIC),
      ],
    );
  }

  Future<Response> get({
    required String url,
    Map<String, String>? headers,
  }) async {
    // obtém token válido (renova automaticamente se expirado)
    final token = await _tokenManager.getToken();

    final defaultHeaders = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final ioClient = IOClient(
      io.HttpClient()
        ..badCertificateCallback =
            (io.X509Certificate cert, String host, int port) => true,
    );

    return ioClient.get(
      Uri.parse(url),
      headers: {...defaultHeaders, ...?headers},
    );
  }
}