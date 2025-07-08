import 'dart:convert';
import 'package:flutter_database_drift/src/core/network/http_client.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/data/datasources/remote/task_remote_data_source.dart';

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final HttpClient _httpClient;

  TaskRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Task> createTask(Task task) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks');
    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks/${task.serverId}');
    final response = await _httpClient.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(int serverId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks/$serverId');
    final response = await _httpClient.delete(url);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }
}
