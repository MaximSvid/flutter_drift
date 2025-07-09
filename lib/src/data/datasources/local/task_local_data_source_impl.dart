import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/data/datasources/local/task_local_data_source.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase _database;

  TaskLocalDataSourceImpl(this._database);

  @override
  Future<List<Task>> getDirtyTask() {
    return _database.getDirtyTasks();
  }

  @override
  Future<void> markAsCreatedOnServer(int localId, int serverId) {
    return _database.markAsCreatedOnServer(localId, serverId);
  }

  @override
  Future<void> markAsSynced(int localId) {
    return _database.markAsSynced(localId);
  }

  @override
  Future<void> deleteTaskPermanently(int localId) {
    return _database.deleteTaskPermanently(localId);
  }

  @override
  Stream<List<Task>> watchAllTasks() {
    return _database.watchAllTasks();
  }

  @override
  Future<int> createTask(TasksCompanion task) {
    return _database.createTask(task);
  }

  @override
  Future<void> updateTask(Task task) {
    return _database.updateTask(task);
  }
}
