import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_database_drift/data/database.dart';
import 'package:flutter_database_drift/data/task_repository.dart';
import 'package:flutter_database_drift/view_model/task_view_model.dart';

import 'task_view_model_test.mocks.dart'; // Сгенерированный файл моков

@GenerateMocks([TaskRepository])
void main() {
  group('TaskViewModel', () {
    late MockTaskRepository mockRepository;
    late TaskViewModel viewModel;

    setUp(() {
      mockRepository = MockTaskRepository();
      // Мокаем watchAllTasks, так как ViewModel сразу его вызывает
      when(mockRepository.watchAllTasks())
          .thenAnswer((_) => Stream.fromIterable([[]]));
      viewModel = TaskViewModel(mockRepository);
    });

    test('tasksStream is initialized from repository', () {
      verify(mockRepository.watchAllTasks()).called(1);
      expect(viewModel.tasksStream, isNotNull);
    });

    test('addNewTask calls addTask on repository', () async {
      when(mockRepository.addTask(any)).thenAnswer((_) async => 1);

      await viewModel.addNewTask('New Task');

      verify(mockRepository.addTask('New Task')).called(1);
    });

    test('toggleTaskStatus calls updateTask on repository with toggled status', () async {
      final task = Task(id: 1, title: 'Test', completed: false);
      when(mockRepository.updateTask(any)).thenAnswer((_) async => true);

      await viewModel.toggleTaskStatus(task);

      verify(mockRepository.updateTask(argThat(isA<Task>()
          .having((t) => t.completed, 'completed', true)))).called(1);
    });

    test('removeTask calls deleteTask on repository', () async {
      final task = Task(id: 1, title: 'Test', completed: false);
      when(mockRepository.deleteTask(any)).thenAnswer((_) async => 1);

      await viewModel.removeTask(task);

      verify(mockRepository.deleteTask(task)).called(1);
    });
  });
}
