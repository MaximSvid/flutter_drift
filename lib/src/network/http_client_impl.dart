import 'package:http/http.dart' as http;
import 'package:flutter_database_drift/src/network/http_client.dart';

class HttpClientImpl implements HttpClient {
  final http.Client _client;

  HttpClientImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding}) {
    return _client.post(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding}) {
    return _client.delete(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding}) {
    return _client.put(url, headers: headers, body: body, encoding: encoding);
  }
}
