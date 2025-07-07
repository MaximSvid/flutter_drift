import 'package:flutter_database_drift/model/database.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchAllTasks(); // Watches and returns a stream of all tasks in the database.
  Future<int> addTask(TasksCompanion entry); // Adds a new task to the database and returns the ID of the newly inserted task.
  Future<bool> updateTask(Task entry);
  Future<int> deleteTask(Task entry);
}