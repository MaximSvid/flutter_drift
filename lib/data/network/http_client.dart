import 'package:http/http.dart' as http;

abstract class HttpClient {
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding});
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding});
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding}); // Added PUT for updates
}
