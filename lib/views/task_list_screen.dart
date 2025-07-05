import 'package:flutter/material.dart';
import 'package:flutter_database_drift/model/database.dart';
import 'package:flutter_database_drift/view_model/task_view_model.dart';
import 'package:provider/provider.dart';

/// A StatelessWidget that displays the list of tasks.
/// It observes the [TaskViewModel] for data changes and dispatches user actions.
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the ViewModel from the Provider
    final viewModel = Provider.of<TaskViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List (MVVM + Drift)'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: viewModel.tasksStream, // Listen to the stream from the ViewModel
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (_) {
                    // Call ViewModel method
                    viewModel.toggleTaskStatus(task);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Call ViewModel method
                    viewModel.removeTask(task);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, viewModel),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows a dialog to add a new task.
  /// [context]: The build context.
  /// [viewModel]: The [TaskViewModel] to interact with.
  void _showAddTaskDialog(BuildContext context, TaskViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Call ViewModel method
                viewModel.addNewTask(controller.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}