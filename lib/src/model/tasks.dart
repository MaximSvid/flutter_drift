import 'package:drift/drift.dart';

/// Enum representing the synchronization status of a task.
/// This is used to track the state of a task in relation to the server.
/// It helps in determining whether a task is synced, pending creation, update, or deletion.
/// This enum is useful for managing the synchronization process and ensuring that the local database
/// and the server are in sync.
enum SyncStatus {
  synced, // Task is synced with the server
  pendingCreate, // Task is pending creation on the server
  pendingUpdate, // Task is pending update on the server
  pendingDelete, // Task is pending deletion on the server
}

class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();

  @override
  SyncStatus fromSql(String fromDb) {
    return SyncStatus.values.byName(fromDb); // Convert string to enum
  }

  @override
  String toSql(SyncStatus value) {
    return value.name; // Convert enum to string
  }
}

/// Represents the 'tasks' table in the database.
/// Each row in this table corresponds to a single to-do item.
class Tasks extends Table {
  // Moved back into this file
  /// Unique identifier for the task. Auto-increments.
  IntColumn get id => integer().autoIncrement()();

  /// Unique identifier for the task, generated on the client side.
  TextColumn get uuid => text().unique()();

  /// The title or description of the task. Must be between 1 and 50 characters.
  TextColumn get title => text().withLength(min: 1, max: 50)();

  /// Indicates whether the task is completed. Defaults to false.
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  //----------Синхронизация с сервером----------//

  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(Constant(SyncStatus.pendingCreate.name))();

  IntColumn get serverId => integer()
      .nullable()(); // ID of the task on the server, nullable if not yet created

  /// Флаг, указывающий, была ли задача удалена. По умолчанию false.
  /// Используется для логического удаления задачи без физического удаления из базы данных.
  /// Это позволяет сохранять историю задач и синхронизировать состояние с сервером.
  /// При удалении задачи на сервере этот флаг устанавливается в true.
  BoolColumn get isDeleted => boolean().withDefault(
    const Constant(false),
  )(); // NEW: Flag to mark task as deleted

  /// Флаг, указывающий, была ли задача синхронизирована с сервером.
  /// По умолчанию false. Устанавливается в true после успешной синхронизации с сервером.
  /// Используется для отслеживания состояния синхронизации задачи.
  BoolColumn get isSynced => boolean().withDefault(
    const Constant(false),
  )(); // NEW: Flag to mark task as synced with server
  //----------Синхронизация с сервером----------//
}
