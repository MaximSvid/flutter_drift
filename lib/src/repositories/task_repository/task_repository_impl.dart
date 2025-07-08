import 'dart:convert';

import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/repositories/task_repository/task_repository.dart';
import 'package:flutter_database_drift/src/core/network/http_client.dart';

/// Implementation of TaskRepository that handles both local database operations
/// and remote API operations with a Spring Boot backend.
/// It uses the AppDatabase for local storage and HttpClient for network requests.
/// This class provides methods to add, update, delete, and watch tasks,
/// ensuring that changes are synchronized between the local database and the server.
/// It also handles sending tasks to the server immediately after local operations.
class TaskRepositoryImplementation implements TaskRepository {
  final AppDatabase _localDb;
  final HttpClient _httpClient;

  TaskRepositoryImplementation(
    this._localDb,
    this._httpClient,
  );

  // Local Database Operations
  @override
  Stream<List<Task>> watchAllTasks() {
    return _localDb.watchAllTasks();
  }

  @override
  Future<int> addTask(TasksCompanion entry) async {
    final localId = await _localDb.addTask(entry);
    print('Task added locally with ID: $localId');
    _sendTaskToServer(entry); // Send to server immediately
    return localId;
  }

  @override
  Future<bool> updateTask(Task entry) async {
    final result = await _localDb.updateTask(entry);
    print('Task updated locally: ${entry.id}');
    _updateTaskToServer(entry); // Send update to server immediately
    return result;
  }

  @override
  Future<int> deleteTask(Task entry) async {
    final result = await _localDb.deleteTask(entry);
    print('Task deleted locally with ID: ${entry.id}');
    _deleteTaskToServer(entry); // Send delete to server immediately
    return result;
  }

  // --- Remote-API-Operations (Spring Boot Backend) ---

  Future<void> _sendTaskToServer(TasksCompanion entry) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks'); // Use 10.0.2.2 for Android emulator
    try {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': entry.title.value,
          'completed': entry.completed.value,
        }),
      );
      if (response.statusCode == 200) {
        print('Task sent to server successfully: ${response.body}');
        // Here you might want to update the local task with the server-assigned ID
      } else {
        print('Failed to send task to server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending task to server: $e');
    }
  }

  Future<void> _updateTaskToServer(Task entry) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks/${entry.id}'); // Use 10.0.2.2 for Android emulator
    try {
      final response = await _httpClient.put( // Use PUT for update
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': entry.id,
          'title': entry.title,
          'completed': entry.completed,
        }),
      );
      if (response.statusCode == 200) {
        print('Task update sent to server successfully');
      } else {
        print('Failed to send task update to server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending task update to server: $e');
    }
  }

  Future<void> _deleteTaskToServer(Task entry) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks/${entry.id}'); // Use 10.0.2.2 for Android emulator
    try {
      final response = await _httpClient.delete( // Use DELETE for delete
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task delete sent to server successfully');
      } else {
        print('Failed to send task delete to server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending task delete to server: $e');
    }
  }
}
