import 'package:flutter_database_drift/src/data/datasources/local/database.dart';

abstract class TaskLocalDataSource {
  Future<List<Task>> getDirtyTask();
  Future<void> markAsCreatedOnServer(int localId, int serverId);
  Future<void> markAsSynced(int localId);
  Future<void> deleteTaskPermanently(int localId);
  Stream<List<Task>> watchAllTasks();
  Future<int> createTask(TasksCompanion task);
  Future<void> updateTask(Task task);
}