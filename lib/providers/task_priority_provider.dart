import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

final taskPriorityProvider = StateNotifierProvider<TaskPriorityNotifier, Map<String, TaskPriority>>((ref) {
  return TaskPriorityNotifier();
});

class TaskPriorityNotifier extends StateNotifier<Map<String, TaskPriority>> {
  TaskPriorityNotifier() : super({});

  void setPriority(String taskId, TaskPriority priority) {
    state = {...state, taskId: priority};
  }

  TaskPriority? getPriority(String taskId) {
    return state[taskId];
  }
} 