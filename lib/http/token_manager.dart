import 'dart:convert';
import 'dart:io' as io;
import 'package:http/io_client.dart';

class TokenManager {
  static const String _clientKey = 'SEU_CLIENT_KEY';
  static const String _clientSecret = 'SEU_CLIENT_SECRET';
  static const String _tokenUrl = 'https://api.metrolisboa.pt:8243/token';

  String? _accessToken;
  DateTime? _expiresAt;

  IOClient _buildClient() {
    final httpClient = io.HttpClient()
      ..badCertificateCallback =
          (io.X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  Future<String> getToken() async {
    if (_accessToken != null &&
        _expiresAt != null &&
        DateTime.now().isBefore(_expiresAt!)) {
      return _accessToken!;
    }

    return await _refreshToken();
  }

  Future<String> _refreshToken() async {
    final credentials =
    base64Encode(utf8.encode('$_clientKey:$_clientSecret'));

    final client = _buildClient();

    try {
      final response = await client.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erro ao renovar token: ${response.statusCode} - ${response.body}');
      }

      final json = jsonDecode(response.body);

      _accessToken = json['access_token'];

      final expiresIn = json['expires_in'] ?? 3600;
      _expiresAt =
          DateTime.now().add(Duration(seconds: expiresIn - 60));

      return _accessToken!;
    } finally {
      client.close();
    }
  }
}