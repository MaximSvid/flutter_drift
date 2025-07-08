import 'dart:ffi';

import 'package:drift/drift.dart';

/// Represents the 'tasks' table in the database.
/// Each row in this table corresponds to a single to-do item.
class Tasks extends Table { // Moved back into this file
  /// Unique identifier for the task. Auto-increments.
  IntColumn get id => integer().autoIncrement()();

  /// The title or description of the task. Must be between 1 and 50 characters.
  TextColumn get title => text().withLength(min: 1, max: 50)();

  /// Indicates whether the task is completed. Defaults to false.
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

//----------Синхронизация с сервером----------//
// Метка времени последнего обновления задачи на сервере.
DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  
  /// Флаг, указывающий, была ли задача удалена. По умолчанию false.
  /// Используется для логического удаления задачи без физического удаления из базы данных.
  /// Это позволяет сохранять историю задач и синхронизировать состояние с сервером.
  /// При удалении задачи на сервере этот флаг устанавливается в true.
  /// При синхронизации с сервером задачи с этим флагом не отправляются.
BoolColumn get isDeleted => boolean().withDefault(const Constant(false))(); // NEW: Flag to mark task as deleted
// Флаг, указывающий, была ли задача синхронизирована с сервером.
  /// По умолчанию false. Устанавливается в true после успешной синхронизации с сервером.
  /// Используется для отслеживания состояния синхронизации задачи.
  /// При синхронизации с сервером задачи с этим флагом отправляются на сервер. 
BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // NEW: Flag to mark task as synced with server

//----------Синхронизация с сервером----------//
  
}

