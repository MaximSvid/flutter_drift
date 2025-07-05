import 'package:flutter/foundation.dart';
import 'package:flutter_database_drift/model/database.dart';
import 'package:flutter_database_drift/repository/task_repository.dart';

/// ViewModel for managing task-related UI logic and data flow.
/// It interacts with the [TaskRepository] to perform data operations
/// and notifies its listeners about changes.
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  /// Stream of tasks that the UI can listen to for real-time updates.
  late final Stream<List<Task>> tasksStream;

  /// Constructs a [TaskViewModel] with the given [TaskRepository] instance.
  TaskViewModel(this._repository) {
    tasksStream = _repository.watchAllTasks();
  }

  // --- Methods called by the View ---

  /// Adds a new task to the repository.
  /// [title]: The title of the new task.
  Future<void> addNewTask(String title) async {
    await _repository.addTask(title);
  }

  /// Toggles the completion status of a given task.
  /// [task]: The task whose status needs to be toggled.
  Future<void> toggleTaskStatus(Task task) async {
    final newStatus = !task.completed;
    await _repository.updateTask(task.copyWith(completed: newStatus));
  }

  /// Removes a task from the repository.
  /// [task]: The task to be removed.
  Future<void> removeTask(Task task) async {
    await _repository.deleteTask(task);
  }
}