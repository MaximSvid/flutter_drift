import 'package:flutter/material.dart';
import 'package:flutter_database_drift/data/database.dart';
import 'package:flutter_database_drift/data/task_repository.dart';
import 'package:flutter_database_drift/view_model/task_view_model.dart';
import 'package:flutter_database_drift/views/task_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // Создаем единственный экземпляр базы данных
  final database = AppDatabase();
  // Создаем единственный экземпляр репозитория
  final repository = TaskRepository(database);
  // Создаем единственный экземplяр ViewModel
  final viewModel = TaskViewModel(repository);

  runApp(
    // Передаем ViewModel в дерево виджетов
    ChangeNotifierProvider(
      create: (context) => viewModel,
      child: const MyApp(),
    ),
  );
}

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