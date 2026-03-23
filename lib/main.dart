import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_test/screens/archive_screen.dart';
import 'package:todo_test/screens/task_detail_screen.dart';
import 'screens/todo_screen.dart';
import 'services/todo_service.dart';
import 'services/objectbox_helper.dart';

late ObjectboxHelper objectbox;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectboxHelper.init();
  final todoService = TodoService();

  runApp(TodoApp(todoService: todoService));
}

// Основной виджет планера
class TodoApp extends StatelessWidget {
  final TodoService todoService;
  TodoApp({super.key, required this.todoService});

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => TodoScreen(todoService: todoService),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) {
          final String idString = state.pathParameters['id']!;
          final int taskId = int.parse(idString);

          return TaskDetailScreen(taskId: taskId, todoService: todoService);
        },
      ),
      GoRoute(
        path: '/archive',
        builder: (context, state) => ArchiveScreen(todoService: todoService),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Todo App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU')],
      locale: const Locale('ru', 'RU'),
    );
  }
}
