import 'package:flutter_database_drift/src/data/datasources/local/database.dart';

abstract class TaskRemoteDataSource {
  Future<Task> createTask(Task task); // должен возвращать задачу с serverId
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int serverId);
}
