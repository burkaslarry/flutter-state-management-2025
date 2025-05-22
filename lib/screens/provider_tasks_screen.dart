// lib/screens/provider_tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart'; // Ensure this path is correct

/// Provider Tasks Screen
/// 
/// This screen demonstrates the Provider pattern:
/// 1. Simple state management using ChangeNotifier
/// 2. Direct state access through Provider.of or Consumer
/// 3. Reactive UI updates with notifyListeners
/// 
/// Key components:
/// - ChangeNotifier: Base class for state management
/// - Consumer: Rebuilds UI based on state changes
/// - Provider: Provides state to widget tree
class ProviderTasksScreen extends StatelessWidget {
  const ProviderTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Tasks'),
      ),
      // Consumer rebuilds only when TaskProvider notifies listeners
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add some!'),
            );
          }
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    // Direct state modification through provider
                    onChanged: (_) => taskProvider.toggleTask(task.id),
                    activeColor: Colors.green,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    task.description.isEmpty ? '(No description)' : task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey : Colors.black54,
                    ),
                  ),
                  // Optional: Add a trailing delete button
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                    onPressed: () => _showDeleteConfirmDialog(context, taskProvider, task.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows a dialog to add a new task
  /// 
  /// Demonstrates:
  /// 1. Form validation
  /// 2. Using Provider to add task
  /// 3. Dialog management
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter task description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Use Provider.of with listen: false for one-time access
                Provider.of<TaskProvider>(context, listen: false).addTask(
                  Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a task
  /// 
  /// Demonstrates:
  /// 1. Confirmation dialog pattern
  /// 2. Using Provider to delete task
  void _showDeleteConfirmDialog(BuildContext context, TaskProvider taskProvider, String taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskProvider.deleteTask(taskId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// TaskProvider class that extends ChangeNotifier for state management
/// 
/// Handles:
/// 1. Task list management
/// 2. Task state modifications
/// 3. Notifying listeners of changes
class TaskProvider extends ChangeNotifier {
  // Private list of tasks
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Learn Provider',
      description: 'Study Provider state management in Flutter.',
    ),
    Task(
      id: '2',
      title: 'Practice Flutter Widgets',
      description: 'Build a sample UI to practice various widgets.',
      isCompleted: true,
    ),
  ];

  // Public getter that returns an unmodifiable list
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Adds a new task and notifies listeners
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // Notify all listeners of the change
  }

  /// Toggles task completion status and notifies listeners
  void toggleTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  /// Deletes a task and notifies listeners
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}