import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_database_drift/data/database.dart';
import 'package:flutter_database_drift/data/task_repository.dart';

import 'task_repository_test.mocks.dart'; // Сгенерированный файл моков

@GenerateMocks([AppDatabase])
void main() {
  group('TaskRepository', () {
    late MockAppDatabase mockAppDatabase;
    late TaskRepository repository;

    setUp(() {
      mockAppDatabase = MockAppDatabase();
      repository = TaskRepository(mockAppDatabase);
    });

    test('watchAllTasks calls watchAllTasks on database', () {
      when(mockAppDatabase.watchAllTasks())
          .thenAnswer((_) => Stream.fromIterable([[]]));

      repository.watchAllTasks();

      verify(mockAppDatabase.watchAllTasks()).called(1);
    });

    test('addTask calls addTask on database', () async {
      when(mockAppDatabase.addTask(any)).thenAnswer((_) async => 1);

      await repository.addTask('Test Task');

      verify(mockAppDatabase.addTask(argThat(isA<TasksCompanion>()
          .having((c) => c.title.value, 'title', 'Test Task')))).called(1);
    });

    test('updateTask calls updateTask on database', () async {
      final task = Task(id: 1, title: 'Old Task', completed: false);
      when(mockAppDatabase.updateTask(any)).thenAnswer((_) async => true);

      await repository.updateTask(task);

      verify(mockAppDatabase.updateTask(task)).called(1);
    });

    test('deleteTask calls deleteTask on database', () async {
      final task = Task(id: 1, title: 'Test Task', completed: false);
      when(mockAppDatabase.deleteTask(any)).thenAnswer((_) async => 1);

      await repository.deleteTask(task);

      verify(mockAppDatabase.deleteTask(task)).called(1);
    });
  });
}
