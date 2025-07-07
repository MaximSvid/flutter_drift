import 'package:http/http.dart' as http;

/// Abstract class defining the interface for an HTTP client.
/// This allows for easy mocking and testing of network requests.
abstract class HttpClient {
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding});
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, dynamic encoding});

}
