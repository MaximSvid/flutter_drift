import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/repositories/task_repository/task_repository.dart';


/// ViewModel for managing task-related UI logic and data flow.
/// It interacts with the [TaskRepository] to perform data operations
/// and notifies its listeners about changes.
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository; // Renamed for consistency

  Stream<List<Task>> get tasks => _taskRepository.watchAllTasks();

  TaskViewModel(this._taskRepository); // Constructor parameter matches field name

  Future<int> addTask(String title) async {
    if (title.isEmpty) return Future.value(0);
    final entry = TasksCompanion(
      title: Value(title),
      completed: const Value(false),
    );
    return await _taskRepository.addTask(entry);
  }

  // NEW: Update task status
  Future<void> updateTaskStatus(Task task, bool completed) async {
    final updatedTask = task.copyWith(completed: completed);
    await _taskRepository.updateTask(updatedTask);
  }

  // NEW: Delete task
  Future<void> deleteTask(Task task) async {
    await _taskRepository.deleteTask(task);
  }
}
