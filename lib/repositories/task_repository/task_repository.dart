import 'package:flutter_database_drift/model/database.dart';

/// Abstract class defining the interface for task-related operations.
/// This allows for easy mocking and testing of task-related data operations.
/// It provides methods to watch all tasks, add a task, update a task, and delete a task.
abstract class TaskRepository {
  Stream<List<Task>> watchAllTasks();
  Future<int> addTask(TasksCompanion entry);
  Future<bool> updateTask(Task entry);
  Future<int> deleteTask(Task entry);
}
