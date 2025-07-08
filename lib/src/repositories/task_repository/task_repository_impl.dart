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
    print('Fetching tasks from local data source');
    return localDataSource.watchAllTasks();
  }

  @override
  Future<int> addTask(TasksCompanion entry) async {
    final localId = await localDataSource.createTask(entry);
    syncService.sync();
    return localId;
  }

  @override
  Future<bool> updateTask(Task entry) async {
    await localDataSource.updateTask(entry.copyWith(syncStatus: SyncStatus.pendingUpdate));
    syncService.sync();
    return true; // Assuming update is always successful locally
  }

  @override
  Future<int> deleteTask(Task entry) async {
    await localDataSource.updateTask(entry.copyWith(syncStatus: SyncStatus.pendingDelete));
    syncService.sync();
    return 1; // Assuming one row is deleted for simplicity, adjust if needed
  }
}
