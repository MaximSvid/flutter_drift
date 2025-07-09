import 'package:flutter/material.dart';

class TaskListDetailScreen extends StatelessWidget {
  const TaskListDetailScreen({required this.taskId, super.key});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: Center(child: Text('Task ID: $taskId')),
    );
  }
}
