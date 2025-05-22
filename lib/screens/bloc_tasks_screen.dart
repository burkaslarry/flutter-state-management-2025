import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task_bloc/task_bloc.dart';
import '../blocs/task_bloc/task_event.dart';
import '../blocs/task_bloc/task_state.dart';
import '../models/task.dart';

/// BLoC Tasks Screen
/// 
/// This screen demonstrates the BLoC (Business Logic Component) pattern:
/// 1. Separation of business logic from UI
/// 2. Event-driven state management
/// 3. Unidirectional data flow
/// 
/// Key components:
/// - BlocBuilder: Rebuilds UI based on state changes
/// - TaskBloc: Manages business logic and state
/// - TaskEvent: Represents user actions
/// - TaskState: Represents the current state
class BlocTasksScreen extends StatelessWidget {
  const BlocTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC Tasks'),
      ),
      // BlocBuilder listens to state changes and rebuilds UI accordingly
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Handle loading state
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Handle error state
          if (state is TasksError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          // Handle loaded state
          if (state is TasksLoaded) {
            if (state.filteredTasks.isEmpty) {
              return const Center(child: Text('No tasks yet. Add some!'));
            }
            return ListView.builder(
              itemCount: state.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = state.filteredTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      // Dispatch ToggleTaskCompletion event
                      onChanged: (_) => context.read<TaskBloc>().add(ToggleTaskCompletion(task.id)),
                      activeColor: Colors.green,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                      onPressed: () => _showDeleteConfirmDialog(context, task.id),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
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
  /// 2. Dispatching AddTask event
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
                // Dispatch AddTask event with new task
                context.read<TaskBloc>().add(AddTask(
                  Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                  ),
                ));
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
  /// 2. Dispatching DeleteTask event
  void _showDeleteConfirmDialog(BuildContext context, String taskId) {
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
              // Dispatch DeleteTask event
              context.read<TaskBloc>().add(DeleteTask(taskId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}