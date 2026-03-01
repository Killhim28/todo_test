import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  const TodoApp({super.key, required this.todoService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: TodoScreen(todoService: todoService),
    );
  }
}
