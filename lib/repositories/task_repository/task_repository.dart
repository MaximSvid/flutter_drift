import 'package:flutter_database_drift/model/database.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchAllTasks();
  Future<int> addTask(TasksCompanion entry);
  Future<bool> updateTask(Task entry);
  Future<int> deleteTask(Task entry);
}
