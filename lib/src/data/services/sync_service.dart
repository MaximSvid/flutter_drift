import 'dart:math';

import 'package:flutter_database_drift/src/data/datasources/local/task_local_data_source.dart';
import 'package:flutter_database_drift/src/data/datasources/remote/task_remote_data_source.dart';
import 'package:flutter_database_drift/src/model/tasks.dart';
import 'package:path/path.dart';

class SyncService {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  bool isSyncing = false; // флаг чтобы избежать паралельных запусков

  SyncService({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<void> sync() async {
    // 1. проверяем не идет ли уже синхронизация
    if (isSyncing) {
      print('SyncService: Sync already in progress. Skipping.');
      return;
    }
    // 2. проверяем наличи интернета
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == connectivityResult.none) {
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
    } finally {
      isSyncing = false; // меняем флаг для новой синхронизации 
    }
  }
}

  // // Главный метод синхронизации
  // Future<void> sync() async {
  //   final connectivityResult = await connectivity.checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     print('No internet connection. Sync aborted.');
  //     return;
  //   }
  //   print('Internet connection detected. Starting sync...');
  //   final dirtyTasks = await localDataSource.getDirtyTasks();
  //   if (dirtyTasks.isEmpty) {
  //     print('No dirty tasks to sync.');
  //     return;
  //   }
  //   print('Found ${dirtyTasks.length} dirty tasks. Syncing...');
  //   for (final task in dirtyTasks) {
  //     try {
  //       switch (task.syncStatus) {
  //         case SyncStatus.pendingCreate:
  //           // отправляем задачу на сервер
  //           final syncedTask = await remoteDataSource.createTask(task);
  //           // обновляем статус задачи в локальной базе данных
  //           await localDataSource.markAsCreatedOnServer(
  //             task.id,
  //             syncedTask.serverId,
  //           );
  //           print('Synced Created task with ID: ${task.id}');
  //           break;
  //         case SyncStatus.pendingUpdate:
  //           await remoteDataSource.updateTask(task);
  //           // обновляем статус задачи в локальной базе данных
  //           await localDataSource.markAsSynced(task.id);
  //           print('Synced Updated task with ID: ${task.id}');
  //           break;
  //         case SyncStatus.pendingDelete:
  //           await remoteDataSource.deleteTask(task.serverId!);
  //           // здесь можно удалить задачу из локальной базы данных
  //           break;
  //         case SyncStatus.synced:
  //           // задача уже синхронизирована, ничего не делаем
  //           print('Task with ID: ${task.id} is already synced.');
  //           break;
  //       }
  //     } catch (e) {
  //       print('Error syncing task with ID: ${task.id}. Error: $e');
  //       // здесь можно обработать ошибку, например, повторить попытку позже
  //     }
  //   }
  //   print('Sync completed successfully.');
  // }
// }
