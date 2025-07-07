import 'package:flutter_database_drift/model/database.dart';
import 'package:drift/drift.dart';

/// A repository class that abstracts the data source for tasks.
/// It acts as an intermediary between the ViewModel and the AppDatabase.
class TaskRepository {
  final AppDatabase _database;

  /// Constructs a [TaskRepository] with the given [AppDatabase] instance.
  TaskRepository(this._database);

  /// Watches and returns a stream of all tasks from the database.
  Stream<List<Task>> watchAllTasks() => _database.watchAllTasks();

  /// Adds a new task to the database.
  /// [title]: The title of the task to be added.
  /// Returns the ID of the newly inserted task.
  Future<int> addTask(String title) {
    final entry = TasksCompanion(title: Value(title));
    return _database.addTask(entry);
  }

  /// Updates an existing task in the database.
  /// [task]: The [Task] object with updated values.
  /// Returns true if the update was successful, false otherwise.
  Future<bool> updateTask(Task task) {
    return _database.updateTask(task);
  }

  /// Deletes a task from the database.
  /// [task]: The [Task] object to be deleted.
  /// Returns the number of rows deleted.
  Future<int> deleteTask(Task task) {
    return _database.deleteTask(task);
  }
}