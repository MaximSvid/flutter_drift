import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:flutter_database_drift/src/data/datasources/local/database.dart';

abstract class TaskLocalDataSource {
  Future<List<Task>> getDirtyTask(); // получить все задачи
  Future<Void> markAsCreatedOnServer(
    int localId,
    int serverId,
  ); // получить задачи которые не synced
  Future<Void> markAsSynced(int localId); // обновить статус
  Future<Void> deleteTaskPermanently(int localId); //удалить задачу
}
