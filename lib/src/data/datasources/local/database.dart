import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_database_drift/src/model/tasks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
  );

  Stream<List<Task>> watchAllTasks() => select(tasks).watch();

  Future<int> createTask(TasksCompanion task) async {
    return await into(tasks).insert(task);
  }

  Future<void> updateTask(Task task) async {
    await update(tasks).replace(task);
  }

  Future<List<Task>> getDirtyTasks() async {
    return (select(tasks)..where(
          (t) =>
              t.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              t.syncStatus.equalsValue(SyncStatus.pendingUpdate) |
              t.syncStatus.equalsValue(SyncStatus.pendingDelete),
        ))
        .get();
  }

  Future<void> markAsCreatedOnServer(int localId, int serverId) async {
    await (update(tasks)..where((t) => t.id.equals(localId))).write(
      TasksCompanion(
        serverId: Value(serverId),
        syncStatus: Value(SyncStatus.synced),
      ),
    );
  }

  Future<void> markAsSynced(int localId) async {
    await (update(tasks)..where((t) => t.id.equals(localId))).write(
      const TasksCompanion(syncStatus: Value(SyncStatus.synced)),
    );
  }

  Future<void> deleteTaskPermanently(int localId) async {
    await (delete(tasks)..where((t) => t.id.equals(localId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
