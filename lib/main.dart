import 'package:flutter/material.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/data/datasources/local/task_local_data_source.dart';
import 'package:flutter_database_drift/src/data/datasources/remote/task_remote_data_source.dart';
import 'package:flutter_database_drift/src/data/datasources/local/task_local_data_source_impl.dart';
import 'package:flutter_database_drift/src/data/datasources/remote/task_remote_data_source_impl.dart';
import 'package:flutter_database_drift/src/data/services/sync_service.dart';
import 'package:flutter_database_drift/src/repositories/task_repository/task_repository.dart';
import 'package:flutter_database_drift/src/repositories/task_repository/task_repository_impl.dart';
import 'package:flutter_database_drift/src/view_model/task_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_database_drift/src/core/network/http_client.dart';
import 'package:flutter_database_drift/src/core/network/http_client_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_database_drift/src/model/tasks.dart'; // Import SyncStatus
import 'package:flutter_database_drift/src/core/router/app_router.dart';

class CustomValueSerializer extends ValueSerializer {
  final ValueSerializer _defaultSerializer =
      driftRuntimeOptions.defaultSerializer;

  @override
  T fromJson<T>(dynamic json) {
    if (T == SyncStatus && json is String) {
      return SyncStatus.values.byName(json.toLowerCase()) as T;
    }
    return _defaultSerializer.fromJson<T>(json);
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is SyncStatus) {
      return value.name;
    }
    return _defaultSerializer.toJson<T>(value);
  }
}

void main() {
  driftRuntimeOptions.defaultSerializer = CustomValueSerializer();
  runApp(
    MultiProvider(
      providers: [
        Provider<HttpClient>(create: (_) => HttpClientImpl()),
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        Provider<TaskLocalDataSource>(
          create: (context) =>
              TaskLocalDataSourceImpl(context.read<AppDatabase>()),
        ),
        Provider<TaskRemoteDataSource>(
          create: (context) =>
              TaskRemoteDataSourceImpl(context.read<HttpClient>()),
        ),
        Provider<Connectivity>(create: (_) => Connectivity()),
        Provider<SyncService>(
          create: (context) => SyncService(
            localDataSource: context.read<TaskLocalDataSource>(),
            remoteDataSource: context.read<TaskRemoteDataSource>(),
            connectivity: context.read<Connectivity>(),
          ),
        ),
        Provider<TaskRepository>(
          create: (context) => TaskRepositoryImplementation(
            localDataSource: context.read<TaskLocalDataSource>(),
            remoteDataSource: context.read<TaskRemoteDataSource>(),
            syncService: context.read<SyncService>(),
          ),
        ),
        ChangeNotifierProvider<TaskViewModel>(
          create: (context) => TaskViewModel(context.read<TaskRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'Drift und Spring Boot Tasks',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}
