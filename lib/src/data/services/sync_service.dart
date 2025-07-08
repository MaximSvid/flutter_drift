import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
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
      print('SyncService: Sync already in progress. Skipping.');
      return;
    }
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('SyncService: No internet connection. Skipping sync.');
      return;
    }
    isSyncing = true;

    try {
      print('SyncService: Starting sync...');
      final dirtyTask = await localDataSource.getDirtyTask();
      if (dirtyTask.isEmpty) {
        print('SyncSevice: No tasks to sync.');
        return;
      }
      print('SyncSecrvice: Found ${dirtyTask.length} tasks to sync.');

      for (final task in dirtyTask) {
        try {
          switch (task.syncStatus) {
            case SyncStatus.pendingCreate:
              final syncedTask = await remoteDataSource.createTask(task);
              await localDataSource.markAsCreatedOnServer(
                task.id,
                syncedTask.serverId!,
              );
              print('Synced Created task with ID: ${task.id}');
              break;
            case SyncStatus.pendingUpdate:
              if (task.serverId != null) {
                await remoteDataSource.updateTask(task);
                await localDataSource.markAsSynced(task.id);
                print('Synced Updated task with ID: ${task.id}');
              } else {
                // This task was marked for update but has no serverId.
                // It means it was never created on the server. Re-mark as pendingCreate.
                print('Warning: Task with ID: ${task.id} is pending update but has no serverId. Re-marking as pendingCreate.');
                await localDataSource.updateTask(task.copyWith(syncStatus: SyncStatus.pendingCreate));
              }
              break;
            case SyncStatus.pendingDelete:
              if (task.serverId != null) {
                await remoteDataSource.deleteTask(task.serverId!);
                await localDataSource.deleteTaskPermanently(task.id);
                print('Synced Deleted task with ID: ${task.id}');
              } else {
                // This task was marked for deletion but has no serverId.
                // It means it was never created on the server. Just delete it locally.
                print('Warning: Task with ID: ${task.id} is pending deletion but has no serverId. Deleting locally only.');
                await localDataSource.deleteTaskPermanently(task.id);
              }
              break;
            case SyncStatus.synced:
              print('Task with ID: ${task.id} is already synced.');
              break;
          }
        } catch (e) {
          print('Error syncing task with ID: ${task.id}. Error: $e');
        }
      }
      print('Sync completed successfully.');
    } finally {
      isSyncing = false;
    }
  }
}