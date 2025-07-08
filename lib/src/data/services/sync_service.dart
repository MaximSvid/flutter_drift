import 'dart:math';

import 'package:flutter_database_drift/src/model/tasks.dart';
import 'package:path/path.dart';

class SyncService {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  SyncService({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  // Главный метод синхронизации
  Future<void> sync() async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Sync aborted.');
      return;
    }
    print('Internet connection detected. Starting sync...');
    final dirtyTasks = await localDataSource.getDirtyTasks();
    if (dirtyTasks.isEmpty) {
      print('No dirty tasks to sync.');
      return;
    }
    print('Found ${dirtyTasks.length} dirty tasks. Syncing...');
    for (final task in dirtyTasks) {
      try {
        switch (task.syncStatus) {
          case SyncStatus.pendingCreate:
            // отправляем задачу на сервер
            final syncedTask = await remoteDataSource.createTask(task);
            // обновляем статус задачи в локальной базе данных
            await localDataSource.markAsCreatedOnServer(
              task.id,
              syncedTask.serverId,
            );
            print('Synced Created task with ID: ${task.id}');
            break;
          case SyncStatus.pendingUpdate:
            await remoteDataSource.updateTask(task);
            // обновляем статус задачи в локальной базе данных
            await localDataSource.markAsSynced(task.id);
            print('Synced Updated task with ID: ${task.id}');
            break;
          case SyncStatus.pendingDelete:
            await remoteDataSource.deleteTask(task.serverId!);
            // здесь можно удалить задачу из локальной базы данных
            break;
          case SyncStatus.synced:
            // задача уже синхронизирована, ничего не делаем
            print('Task with ID: ${task.id} is already synced.');
            break;
        }
      } catch (e) {
        print('Error syncing task with ID: ${task.id}. Error: $e');
        // здесь можно обработать ошибку, например, повторить попытку позже
      }
    }
    print('Sync completed successfully.');
  }
}
