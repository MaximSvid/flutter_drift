import 'package:flutter/foundation.dart';
import 'package:flutter_database_drift/data/database.dart';
import 'package:flutter_database_drift/data/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  // Поток задач, который будет слушать View
  late final Stream<List<Task>> tasksStream;

  TaskViewModel(this._repository) {
    tasksStream = _repository.watchAllTasks();
  }

  // --- Методы, которые будет вызывать View ---

  // Добавить новую задачу
  Future<void> addNewTask(String title) async {
    await _repository.addTask(title);
  }

  // Изменить статус выполнения задачи
  Future<void> toggleTaskStatus(Task task) async {
    final newStatus = !task.completed;
    await _repository.updateTask(task.copyWith(completed: newStatus));
  }

  // Удалить задачу
  Future<void> removeTask(Task task) async {
    await _repository.deleteTask(task);
  }
}
