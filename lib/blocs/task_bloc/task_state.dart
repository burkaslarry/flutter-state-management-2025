import 'package:equatable/equatable.dart';
import '../../models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TasksLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final bool? showCompleted;

  const TasksLoaded({
    required this.tasks,
    required this.filteredTasks,
    this.showCompleted,
  });

  TasksLoaded copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    bool? showCompleted,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }

  @override
  List<Object?> get props => [tasks, filteredTasks, showCompleted];
}

class TasksError extends TaskState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
} 