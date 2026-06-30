import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state.status == TaskStatus.loading ||
              state.status == TaskStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TaskStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
          }

          if (state.tasks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No tasks yet.\nTap + to add your first task.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final pending = state.tasks.where((t) => !t.isCompleted).toList();
          final completed = state.tasks.where((t) => t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              ...pending.map((task) => TaskTile(task: task)),
              if (completed.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                  child: Text(
                    'Completed (${completed.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...completed.map((task) => TaskTile(task: task)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
