import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolistapp/home/homescreen.dart';
import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';

const String taskBoxName = 'tasks';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final taskBox = await Hive.openBox(taskBoxName);

  runApp(MyApp(taskBox: taskBox));
}

class MyApp extends StatelessWidget {
  final Box taskBox;

  const MyApp({super.key, required this.taskBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc(taskBox: taskBox)..add(const LoadTasks()),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
