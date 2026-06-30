import 'package:equatable/equatable.dart';
import 'package:todolistapp/model/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Loads all tasks from Hive into the bloc's state.
class LoadTasks extends TaskEvent {
  const LoadTasks();
}

/// Adds a brand-new task.
class AddTask extends TaskEvent {
  final String title;
  final String description;

  const AddTask({required this.title, this.description = ''});

  @override
  List<Object?> get props => [title, description];
}

/// Updates an existing task (title, description, and/or completion state).
class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// Toggles a task's completed flag.
class ToggleTaskStatus extends TaskEvent {
  final String taskId;

  const ToggleTaskStatus(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Deletes a task by id.
class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
