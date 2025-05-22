import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<FilterTasks>(_onFilterTasks);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TasksLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final tasks = [
        Task(
          id: '1',
          title: 'Complete Flutter Project',
          description: 'Finish the state management demo app',
        ),
        Task(
          id: '2',
          title: 'Learn BLoC Pattern',
          description: 'Study BLoC pattern implementation',
        ),
        Task(
          id: '3',
          title: 'Master Riverpod',
          description: 'Deep dive into Riverpod state management',
        ),
      ];
      emit(TasksLoaded(
        tasks: tasks,
        filteredTasks: tasks,
        showCompleted: true,
      ));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final updatedTasks = [...currentState.tasks, event.task];
      final filteredTasks = _filterTasks(updatedTasks, currentState.showCompleted);
      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));
    }
  }

  void _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == event.taskId) {
          return task.copyWith(isCompleted: !task.isCompleted);
        }
        return task;
      }).toList();
      final filteredTasks = _filterTasks(updatedTasks, currentState.showCompleted);
      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));
    }
  }

  void _onFilterTasks(
    FilterTasks event,
    Emitter<TaskState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final filteredTasks = _filterTasks(currentState.tasks, event.showCompleted);
      emit(currentState.copyWith(
        filteredTasks: filteredTasks,
        showCompleted: event.showCompleted,
      ));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final updatedTasks = currentState.tasks.where((task) => task.id != event.taskId).toList();
      final filteredTasks = _filterTasks(updatedTasks, currentState.showCompleted);
      emit(currentState.copyWith(
        tasks: updatedTasks,
        filteredTasks: filteredTasks,
      ));
    }
  }

  List<Task> _filterTasks(List<Task> tasks, bool? showCompleted) {
    if (showCompleted == null || showCompleted) return tasks;
    return tasks.where((task) => !task.isCompleted).toList();
  }
} 