import 'package:flutter_database_drift/src/data/datasources/local/database.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchAllTasks();
  Future<void> insertTask(TasksCompanion task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(Task task);
  Future<void> synchronize();
}
