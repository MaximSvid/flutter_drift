import 'package:flutter/material.dart';
import 'package:flutter_database_drift/model/database.dart';
import 'package:flutter_database_drift/repository/task_repository.dart';
import 'package:flutter_database_drift/view_model/task_view_model.dart';
import 'package:flutter_database_drift/views/task_list_screen.dart';
import 'package:provider/provider.dart';

/// Main entry point of the Flutter application.
void main() {
  // Create a single instance of the database
  final database = AppDatabase();
  // Create a single instance of the repository, injecting the database
  final repository = TaskRepository(database);
  // Create a single instance of the ViewModel, injecting the repository
  final viewModel = TaskViewModel(repository);

  runApp(
    // Provide the ViewModel to the widget tree using ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => viewModel,
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
      title: 'MVVM Drift To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        
      ),
      home: const TaskListScreen(),
    );
  }
}
