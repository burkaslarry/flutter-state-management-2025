import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../blocs/task_bloc/task_bloc.dart';
import '../blocs/task_bloc/task_event.dart';
import '../blocs/task_bloc/task_state.dart';
import '../models/task.dart';
import '../providers/selected_task_provider.dart';
import '../providers/task_priority_provider.dart';
import '../widgets/task_list_item.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          // Filter toggle button
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TasksLoaded) {
                return IconButton(
                  icon: Icon(
                    state.showCompleted == true
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  onPressed: () {
                    context.read<TaskBloc>().add(
                          FilterTasks(
                            showCompleted: !(state.showCompleted ?? true),
                          ),
                        );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskInitial) {
            context.read<TaskBloc>().add(const LoadTasks());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is TasksLoaded) {
            return Row(
              children: [
                // Task List
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = state.filteredTasks[index];
                            return TaskListItem(
                              task: task,
                              onTap: () {
                                ref.read(selectedTaskProvider.notifier).state = task;
                              },
                              onToggleComplete: () {
                                context.read<TaskBloc>().add(
                                      ToggleTaskCompletion(task.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Selected Task Details
                Expanded(
                  flex: 1,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final selectedTask = ref.watch(selectedTaskProvider);
                      if (selectedTask == null) {
                        return const Center(
                          child: Text('Select a task to view details'),
                        );
                      }

                      final priority = ref.watch(
                        taskPriorityProvider.select(
                          (priorities) => priorities[selectedTask.id],
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedTask.title,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                  ),
                                  Checkbox(
                                    value: selectedTask.isCompleted,
                                    onChanged: (_) {
                                      context.read<TaskBloc>().add(
                                            ToggleTaskCompletion(selectedTask.id),
                                          );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedTask.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              // Priority selector
                              DropdownButton<TaskPriority>(
                                value: priority ?? selectedTask.priority,
                                items: TaskPriority.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(p.toString().split('.').last),
                                  );
                                }).toList(),
                                onChanged: (newPriority) {
                                  if (newPriority != null) {
                                    ref
                                        .read(taskPriorityProvider.notifier)
                                        .setPriority(selectedTask.id, newPriority);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
} 