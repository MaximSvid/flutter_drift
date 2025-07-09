import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_database_drift/src/data/datasources/local/task_local_data_source.dart';
import 'package:flutter_database_drift/src/data/datasources/remote/task_remote_data_source.dart';
import 'package:flutter_database_drift/src/model/tasks.dart';

class SyncService {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  bool isSyncing = false;

  SyncService({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<void> sync() async {
    if (isSyncing) {
      debugPrint('SyncService: Sync already in progress. Skipping.');
      return;
    }
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('SyncService: No internet connection. Skipping sync.');
      return;
    }
    isSyncing = true;

    try {
      debugPrint('SyncService: Starting sync...');
      final dirtyTask = await localDataSource.getDirtyTask();
      if (dirtyTask.isEmpty) {
        debugPrint('SyncSevice: No tasks to sync.');
        return;
      }
      debugPrint('SyncSecrvice: Found ${dirtyTask.length} tasks to sync.');

      for (final task in dirtyTask) {
        try {
          switch (task.syncStatus) {
            case SyncStatus.pendingCreate:
              final syncedTask = await remoteDataSource.createTask(task);
              await localDataSource.markAsCreatedOnServer(
                task.id,
                syncedTask.serverId!,
              );
              debugPrint('Synced Created task with ID: ${task.id}');
              break;
            case SyncStatus.pendingUpdate:
              if (task.serverId != null) {
                await remoteDataSource.updateTask(task);
                await localDataSource.markAsSynced(task.id);
                debugPrint('Synced Updated task with ID: ${task.id}');
              } else {
                // This task was marked for update but has no serverId.
                // It means it was never created on the server. Re-mark as pendingCreate.
                debugPrint(
                  'Warning: Task with ID: ${task.id} is pending update but has no serverId. Re-marking as pendingCreate.',
                );
                await localDataSource.updateTask(
                  task.copyWith(syncStatus: SyncStatus.pendingCreate),
                );
              }
              break;
            case SyncStatus.pendingDelete:
              if (task.serverId != null) {
                await remoteDataSource.deleteTask(task.serverId!);
                await localDataSource.deleteTaskPermanently(task.id);
                debugPrint('Synced Deleted task with ID: ${task.id}');
              } else {
                // This task was marked for deletion but has no serverId.
                // It means it was never created on the server. Just delete it locally.
                debugPrint(
                  'Warning: Task with ID: ${task.id} is pending deletion but has no serverId. Deleting locally only.',
                );
                await localDataSource.deleteTaskPermanently(task.id);
              }
              break;
            case SyncStatus.synced:
              debugPrint('Task with ID: ${task.id} is already synced.');
              break;
          }
        } catch (e) {
          debugPrint('Error syncing task with ID: ${task.id}. Error: $e');
        }
      }
      debugPrint('Sync completed successfully.');
    } finally {
      isSyncing = false;
    }
  }
}
