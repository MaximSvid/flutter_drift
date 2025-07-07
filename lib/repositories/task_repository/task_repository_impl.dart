import 'dart:convert';

import 'package:flutter_database_drift/model/database.dart';
import 'package:flutter_database_drift/repositories/task_repository/task_repository.dart';
import 'package:flutter_database_drift/data/network/http_client.dart'; // NEW import

class TaskRepositoryImplementation implements TaskRepository {
  final AppDatabase _localDb;
  final HttpClient _httpClient; // NEW: Use our abstract HttpClient

  TaskRepositoryImplementation(
    this._localDb,
    this._httpClient, // NEW: Receive HttpClient via constructor
  );

  // Local Database Operations
  @override
  Stream<List<Task>> watchAllTasks() {
    return _localDb.watchAllTasks();
  }

  @override
  Future<int> addTask(TasksCompanion entry) async {
    final localId = await _localDb.addTask(entry);
    print('Task added with ID: $localId');
    // Now _sendTaskToServer returns Future<void>
    _sendTaskToServer(entry); // Still fire-and-forget for UI responsiveness
    return localId;
  }

  @override
  Future<bool> updateTask(Task entry) async {
    final result = await _localDb.updateTask(entry);
    // NEW: Send update to server
    _updateTaskToServer(entry);
    return result;
  }

  @override
  Future<int> deleteTask(Task entry) async {
    final result = await _localDb.deleteTask(entry);
    print('Task deleted with ID: ${entry.id}');
    // NEW: Send delete to server
    _deleteTaskToServer(entry);
    return result;
  }

  // --- Remote-API-Operations (Spring Boot Backend) ---

  // Modified to return Future<void> for better testability
  Future<void> _sendTaskToServer(TasksCompanion entry) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks'); // CHANGED to 10.0.2.2
    try {
      final response = await _httpClient.post( // Use _httpClient here
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': entry.title.value,
          'completed': entry.completed.value,
        }),
      );
      if (response.statusCode == 200) {
        print('Task sent to server successfully');
      } else {
        print('Failed to send task to server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending task to server: $e');
    }
  }

  // NEW: Method to send task update to server
  Future<void> _updateTaskToServer(Task entry) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks/${entry.id}'); // CHANGED to 10.0.2.2
    try {
      final response = await _httpClient.post( // Using POST for simplicity, ideally PUT
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': entry.id, // Include ID for update
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

  // NEW: Method to send task delete to server
  Future<void> _deleteTaskToServer(Task entry) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/tasks/${entry.id}'); // CHANGED to 10.0.2.2
    try {
      final response = await _httpClient.delete( // Using POST for simplicity, ideally DELETE
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': entry.id, // Include ID for delete
        }),
      );
      if (response.statusCode == 200) {
        print('Task delete sent to server successfully');
      } else {
        print('Failed to send task delete to server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending task delete to server: $e');
    }
  }
}
