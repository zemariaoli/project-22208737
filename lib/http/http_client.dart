import 'dart:io' as io;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

class HttpClient {
  static const String _token = 'fbdd6ed3-3a52-3388-90ae-02e2a00df92c';

  late final HttpWithMiddleware client;

  HttpClient() {
    client = HttpWithMiddleware.build(
      middlewares: [
        HttpLogger(logLevel: LogLevel.BASIC),
      ],
    );
  }

  Future<Response> get({required String url, Map<String, String>? headers}) {
    final defaultHeaders = {
      'Authorization': 'Bearer $_token',
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