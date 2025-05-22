import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart'; // Ensure this path is correct

// Provider for managing the list of tasks
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

// Provider for managing the visibility filter for completed tasks
final showCompletedProvider = StateProvider<bool>((ref) => true);

// Provider for the filtered list of tasks based on the showCompletedProvider
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  return showCompleted
      ? tasks
      : tasks.where((task) => !task.isCompleted).toList();
});

// Notifier class for managing task state
class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier()
      : super([
          Task(
            id: '1',
            title: 'Learn Riverpod',
            description: 'Study Riverpod state management fundamentals.',
          ),
          Task(
            id: '2',
            title: 'Practice Riverpod',
            description: 'Implement a sample app using Riverpod for state management.',
          ),
        ]);

  // Adds a new task to the list
  void addTask(Task task) {
    state = [...state, task]; // Create a new list with the added task
  }

  // Toggles the completion status of a task
  void toggleTask(String id) {
    state = state.map((task) {
      if (task.id == id) {
        // Use copyWith to create an updated immutable Task instance
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList(); // Create a new list with the modified task
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

// The main screen widget for displaying tasks
class RiverpodTasksScreen extends ConsumerWidget {
  const RiverpodTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered list of tasks and the filter state
    final tasks = ref.watch(filteredTasksProvider);
    final showCompleted = ref.watch(showCompletedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Tasks'),
        actions: [
          // Button to toggle the visibility of completed tasks
          IconButton(
            icon: Icon(
              showCompleted ? Icons.check_circle : Icons.check_circle_outline,
            ),
            onPressed: () {
              // Update the state of showCompletedProvider
              ref.read(showCompletedProvider.notifier).state = !showCompleted;
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Add some!'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => ref.read(tasksProvider.notifier).toggleTask(task.id),
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
                      onPressed: () => _showDeleteConfirmDialog(context, ref, task.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Shows a dialog to add a new task
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
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
                ref.read(tasksProvider.notifier).addTask(
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

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, String taskId) {
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
              ref.read(tasksProvider.notifier).deleteTask(taskId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}