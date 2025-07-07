import 'package:drift/drift.dart';

/// Represents the 'sync_queue' table in the database.
/// This table stores operations that need to be synchronized with the server.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationType => text().withLength(min: 1, max: 50)(); // e.g., 'add', 'update', 'delete'
  TextColumn get entityType => text().withLength(min: 1, max: 50)();    // e.g., 'task'
  TextColumn get payload => text()(); // JSON string of the data to sync (removed minLength for flexibility)
  IntColumn get localId => integer().nullable()(); // Local ID of the entity, if applicable
  IntColumn get serverId => integer().nullable()(); // Server ID of the entity, once synced
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // True if successfully synced
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)(); // Added default value
}