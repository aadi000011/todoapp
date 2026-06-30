import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistapp/model/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';



Future<void> showTaskFormDialog(BuildContext context, {Task? existingTask}) {
  final titleController =
      TextEditingController(text: existingTask?.title ?? '');
  final descController =
      TextEditingController(text: existingTask?.description ?? '');
  final formKey = GlobalKey<FormState>();
  final isEditing = existingTask != null;

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final bloc = context.read<TaskBloc>();
              if (isEditing) {
                bloc.add(UpdateTask(existingTask.copyWith(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                )));
              } else {
                bloc.add(AddTask(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                ));
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );
}
