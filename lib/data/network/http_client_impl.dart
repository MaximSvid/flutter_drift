import 'package:http/http.dart' as http;
import 'package:flutter_database_drift/data/network/http_client.dart';

/// Concrete implementation of HttpClient using the http package.
class HttpClientImpl implements HttpClient {
  final http.Client _client;

  HttpClientImpl({http.Client? client}) : _client = client ?? http.Client();
  
  // Implementing the post method as per the abstract class
  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding}) {
    return _client.post(url, headers: headers, body: body, encoding: encoding);
  }
  // Implementing the delete method as per the abstract class
  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, encoding}) {
    return _client.delete(url, headers: headers, body: body, encoding: encoding);
  }

  // Implement other HTTP methods if added to the abstract class
}
