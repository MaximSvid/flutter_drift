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
}