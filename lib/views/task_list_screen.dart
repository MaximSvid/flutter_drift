import 'package:flutter/material.dart';
import 'package:flutter_database_drift/model/database.dart';
import 'package:flutter_database_drift/view_model/task_view_model.dart';
import 'package:provider/provider.dart';

/// A StatelessWidget that displays the list of tasks.
/// It observes the [TaskViewModel] for data changes and dispatches user actions.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the TaskViewModel from the context
    final taskViewModel = Provider.of<TaskViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: StreamBuilder<List<Task>>(
        stream: taskViewModel
            .tasks, // Listen to the stream of tasks from the TaskViewModel
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Show a loading indicator while waiting for data
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            ); // Display an error message if there's an error
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tasks available'),
            ); // Show a message if there are no tasks
          }
          final tasks =
              snapshot.data!; // Get the list of tasks from the snapshot
          return ListView.builder(
            itemCount: tasks.length, // Set the number of items in the list
            itemBuilder: (context, index) {
              final task = tasks[index]; // Get the task at the current index
              return ListTile(
                title: Text(task.title), // Display the task title
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      taskViewModel.updateTaskStatus(task, newValue); // Call ViewModel method
                    }
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    taskViewModel.deleteTask(task); // Call ViewModel method
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, taskViewModel); // Pass viewModel to dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Moved inside the State class and accepts TaskViewModel
  void _showAddTaskDialog(BuildContext context, TaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: _taskController, // Use the state's controller
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.addTask(_taskController.text); // Call ViewModel method
                _taskController.clear(); // Clear the input field
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}