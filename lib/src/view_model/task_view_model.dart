import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/model/tasks.dart';
import 'package:flutter_database_drift/src/repositories/task_repository/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository;

  Stream<List<Task>> get tasks => _taskRepository.watchAllTasks();

  TaskViewModel(this._taskRepository);

  Future<void> addTask(String uuid, String title) async {
    if (title.isEmpty) return;
    final task = TasksCompanion(
      uuid: Value(uuid),
      title: Value(title),
      completed: const Value(false),
      isDeleted: const Value(false),
      isSynced: const Value(false),
      syncStatus: const Value(SyncStatus.PENDING_CREATE),
    );
    await _taskRepository.insertTask(task);
  }

  Future<void> updateTaskStatus(Task task, bool completed) async {
    final updatedTask = task.copyWith(
      completed: completed,
      syncStatus: SyncStatus.PENDING_UPDATE,
    );
    await _taskRepository.updateTask(updatedTask);
  }

  Future<void> deleteTask(Task task) async {
    final deletedTask = task.copyWith(
      isDeleted: true,
      syncStatus: SyncStatus.PENDING_DELETE,
    );
    await _taskRepository.updateTask(deletedTask);
  }

  Future<void> synchronize() async {
    await _taskRepository.synchronize();
    notifyListeners();
  }
}
