import 'package:flutter/material.dart';
import 'package:flutter_database_drift/src/data/datasources/local/database.dart';
import 'package:flutter_database_drift/src/model/tasks.dart';
import 'package:flutter_database_drift/src/view_model/task_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

/// A StatelessWidget that displays the list of tasks.
/// It observes the [TaskViewModel] for data changes and dispatches user actions.
class TaskListScreen extends StatelessWidget {
  // Keeping as StatelessWidget
  const TaskListScreen({super.key});

  // Create a Uuid generator instance
  static final _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    // Retrieve the ViewModel from the Provider
    // Removed listen: false as StreamBuilder handles listening
    final viewModel = Provider.of<TaskViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Task List (MVVM + Drift)')),
      body: StreamBuilder<List<Task>>(
        stream: viewModel.tasks, // CHANGED: from tasksStream to tasks
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                onTap: () {
                  context.go('/list/${task.uuid}');
                },
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                // как здесь сделать лампочку - если задача синхранзирована с сервером, то она должна быть зеленой
                // если задача не синхронезирована с сервером, то она должна быть красной
                leading: Icon(
                  task.syncStatus == SyncStatus.SYNCED
                      ? Icons.check_circle
                      : Icons.error,
                  color: task.syncStatus == SyncStatus.SYNCED
                      ? Colors.green
                      : Colors.red,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    context.go('/list/${task.uuid}');
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
                // Generate a new UUID
                final newUuid = _uuid.v4();
                // Call ViewModel method with UUID
                viewModel.addTask(newUuid, controller.text); // Pass UUID
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
