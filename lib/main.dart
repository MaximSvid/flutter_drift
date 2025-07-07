import 'package:flutter/material.dart';
import 'package:flutter_database_drift/model/database.dart';
import 'package:flutter_database_drift/repositories/task_repository/task_repository.dart';
import 'package:flutter_database_drift/repositories/task_repository/task_repository_impl.dart';
import 'package:flutter_database_drift/view_model/task_view_model.dart';
import 'package:flutter_database_drift/views/task_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_database_drift/data/network/http_client.dart';
import 'package:flutter_database_drift/data/network/http_client_impl.dart';

/// Main entry point of the Flutter application.
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Provide HttpClient
        Provider<HttpClient>( // NEW
          create: (_) => HttpClientImpl(), // NEW
        ), // NEW
        // 1. Drift database instance
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(), // Ensure the database is closed when the app is disposed
        ),
        // 2. Task repository instance
        Provider<TaskRepository>(
          create: (context) => TaskRepositoryImplementation(
            context.read<AppDatabase>(),
            context.read<HttpClient>(), // NEW: Pass HttpClient to repository
          ),
        ),
        // 3. Task ViewModel instance
        ChangeNotifierProvider<TaskViewModel>(
          create: (context) => TaskViewModel(
            context.read<TaskRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift und Spring Boot Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
    );
  }
}