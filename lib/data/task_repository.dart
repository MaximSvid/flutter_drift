import 'package:drift/drift.dart';
import 'package:flutter_database_drift/data/database.dart';

class TaskRepository {
  final AppDatabase _database;

  TaskRepository(this._database);

  // Получить поток всех задач
  Stream<List<Task>> watchAllTasks() => _database.watchAllTasks();

  // Добавить новую задачу
  Future<int> addTask(String title) {
    final entry = TasksCompanion(title: Value(title));
    return _database.addTask(entry);
  }

  // Обновить задачу (например, изменить статус completed)
  Future<bool> updateTask(Task task) {
    return _database.updateTask(task);
  }

  // Удалить задачу
  Future<int> deleteTask(Task task) {
    return _database.deleteTask(task);
  }
}
