import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:todolistapp/model/task.dart';
import 'package:uuid/uuid.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  // A plain, untyped Hive box. Each entry's value is a Map<String, dynamic>
  // (JSON), not a Task/HiveObject instance.
  final Box taskBox;
  final _uuid = const Uuid();

  TaskBloc({required this.taskBox}) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<DeleteTask>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      final tasks = taskBox.values
          .map((json) => Task.fromJson(Map<dynamic, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(status: TaskStatus.success, tasks: tasks));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to load tasks: $e',
      ));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final task = Task(
        id: _uuid.v4(),
        title: event.title,
        description: event.description,
        createdAt: DateTime.now(),
      );
      // CREATE: store the task's JSON map in Hive, keyed by its own id.
      await taskBox.put(task.id, task.toJson());
      add(const LoadTasks());
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to add task: $e',
      ));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      // UPDATE: overwrite the existing entry's JSON with the new JSON.
      await taskBox.put(event.task.id, event.task.toJson());
      add(const LoadTasks());
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to update task: $e',
      ));
    }
  }

  Future<void> _onToggleTaskStatus(
      ToggleTaskStatus event, Emitter<TaskState> emit) async {
    try {
      final json = taskBox.get(event.taskId);
      if (json != null) {
        final task = Task.fromJson(Map<dynamic, dynamic>.from(json));
        final updated = task.copyWith(isCompleted: !task.isCompleted);
        await taskBox.put(updated.id, updated.toJson());
        add(const LoadTasks());
      }
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to update task: $e',
      ));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      // DELETE: remove the entry from the Hive box.
      await taskBox.delete(event.taskId);
      add(const LoadTasks());
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to delete task: $e',
      ));
    }
  }
}
