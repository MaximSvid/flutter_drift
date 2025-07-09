import 'package:flutter/foundation.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/data/datasources/local/task_local_data_source.dart';
import 'package:flutter_database_drift/src/data/datasources/remote/task_remote_data_source.dart';
import 'package:flutter_database_drift/src/data/services/sync_service.dart';
import 'package:flutter_database_drift/src/repositories/task_repository/task_repository.dart';
import 'package:flutter_database_drift/src/model/tasks.dart';

class TaskRepositoryImplementation implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final SyncService syncService;

  TaskRepositoryImplementation({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncService,
  });

  @override
  Stream<List<Task>> watchAllTasks() {
    debugPrint('Fetching tasks from local data source');
    return localDataSource.watchAllTasks();
  }

  @override
  Future<void> insertTask(TasksCompanion task) async {
    await localDataSource.createTask(task);
    await syncService.sync();
  }

  @override
  Future<void> updateTask(Task task) async {
    await localDataSource.updateTask(task);
    await syncService.sync();
  }

  @override
  Future<void> deleteTask(Task task) async {
    final taskToDelete = task.copyWith(
      isDeleted: true,
      syncStatus: SyncStatus.pendingDelete,
    );
    await localDataSource.updateTask(taskToDelete);
    await syncService.sync();
  }

  @override
  Future<void> synchronize() async {
    await syncService.sync();
  }
}
