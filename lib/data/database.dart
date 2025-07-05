import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';
/// База данных Drift для хранения задач
/// Используется для хранения задач в приложении ToDo
/// Модель базы данных реализована с помощью Drift.
// 1. Определяем таблицу
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

// 2. Определяем класс базы данных
@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- Методы для работы с данными (часть Модели) ---

  // Получить поток всех задач. View будет его слушать.
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();

  // Добавить новую задачу
  Future<int> addTask(TasksCompanion entry) {
    return into(tasks).insert(entry);
  }

  // Обновить задачу (например, изменить статус completed)
  Future<bool> updateTask(Task entry) {
    return update(tasks).replace(entry);
  }

  // Удалить задачу
  Future<int> deleteTask(Task entry) {
    return delete(tasks).delete(entry);
  }
}

// 3. Функция для открытия соединения с БД
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
