import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todolistapp/model/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'task_form_dialog.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(Icons.delete,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete task?'),
                content: Text('Delete "${task.title}" permanently?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        // DELETE
        context.read<TaskBloc>().add(DeleteTask(task.id));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) {
              // UPDATE (toggle complete)
              context.read<TaskBloc>().add(ToggleTaskStatus(task.id));
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Theme.of(context).disabledColor
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) Text(task.description),
              Text(
                DateFormat('MMM d, y · h:mm a').format(task.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          isThreeLine: task.description.isNotEmpty,
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showTaskFormDialog(context, existingTask: task),
          ),
          onTap: () => showTaskFormDialog(context, existingTask: task),
        ),
      ),
    );
  }
}
