import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Для работы с JSON

void main() {
  runApp(const TodoApp());
}

// Основной виджет планера
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'), // Русский
      ],
      locale: const Locale('ru', 'RU'),
      home: const TodoScreen(),
    );
  }
}

// Виджет с сохранением состояния поля планера задач
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _todos = [];
  DateTime? _tempSelectedDate;

  // Метод открытия календаря
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );

    if (pickedDate != null) {
      setState(() {
        _tempSelectedDate = pickedDate; // Сохраняем выбор
      });
    }
  }

  // Метод добавления задачи и словарь с задачей
  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add({
          "title": _controller.text,
          "date": _tempSelectedDate ?? DateTime.now(),
          "completed": false,
        });
        _controller.clear();
        _tempSelectedDate = null; // Сбрасываем дату после добавления
      });
      _saveTodos(); // Сохраняем после добавления
    }
  }

  // Метод удаления задачи
  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos(); // Сохраняем после добавления
  }

  // Метод шторки
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Отступ снизу равен высоте клавиатуры
          ),
          child: SizedBox(
            height: 100,
            child: Center(
              child: SingleChildScrollView(
                child: TodoInputWidget(
                  controller: _controller,
                  onAddPressed: () {
                    _addTodo();
                    Navigator.pop(context);
                  },
                  onDatePressed: _pickDate,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Метод редактирования задач
  void _showEditSheet(int index) {
    _controller.text = _todos[index]['title'];
    _tempSelectedDate =
        _todos[index]['date']; // Загружаем старую дату тоже (если она есть)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Отступ снизу равен высоте клавиатуры
          ),
          child: SizedBox(
            height: 100,
            child: Center(
              child: SingleChildScrollView(
                child: TodoInputWidget(
                  controller: _controller,
                  onAddPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _todos[index] = {
                          "title": _controller.text,
                          "date":
                              _tempSelectedDate ?? (DateTime.now().toString()),
                          "completed": _todos[index]['completed'],
                        };
                        _controller.clear();
                        _tempSelectedDate = null;
                      });
                      _saveTodos(); // Сохраняем после добавления
                    }
                    Navigator.pop(context);
                  },
                  onDatePressed: _pickDate,
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _controller.clear();
      _tempSelectedDate = null;
    });
  }

  // Метод переключения галочки чекбокса
  void _toggleTodo(int index, bool value) {
    setState(() {
      _todos[index]['completed'] = value; // Обновляем словарь todos состояния
    });
    _saveTodos(); // Сохраняем после добавления
  }

  // Метод сохранения данных
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Преобразуем список задач в список строк JSON
    List<String> todosJson = _todos.map((todo) {
      return jsonEncode({
        'title': todo['title'],
        'date': todo['date'].toIso8601String(),
        'completed': todo['completed'],
      });
    }).toList();
    await prefs.setStringList('todos', todosJson);
  }

  // Метод сохранения данных
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todosJson = prefs.getStringList('todos');
    if (todosJson != null) {
      setState(() {
        _todos.clear();
        _todos.addAll(
          todosJson.map((todoString) {
            final Map<String, dynamic> todoMap = jsonDecode(todoString);
            return {
              'title': todoMap['title'],
              'date': DateTime.parse(todoMap['date']),
              'completed': todoMap['completed'],
            };
          }).toList(),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать в планер дня :)')),
      body: _todos.isEmpty
          ? const Center(child: Text("Задач нет. Добавим первую?"))
          : TodoListWidget(
              todos: _todos,
              onDelete: _removeTodo,
              onToggle: _toggleTodo,
              onEditTodo: _showEditSheet,
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Виджет ввода текста в поле ввода задачи
class TodoInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddPressed;
  final VoidCallback onDatePressed;

  const TodoInputWidget({
    super.key,
    required this.controller,
    required this.onAddPressed,
    required this.onDatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              onSubmitted: (text) {
                onAddPressed();
              },
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Ограничение размера, займет столько места сколько потребуется
                  children: [
                    IconButton(
                      onPressed: onDatePressed,
                      icon: Icon(Icons.calendar_month),
                    ),
                    IconButton(onPressed: onAddPressed, icon: Icon(Icons.send)),
                    SizedBox(width: 5),
                  ],
                ),
                hintText: 'Добавить новую задачу...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// Виджет хранения задач
class TodoListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> todos;
  final Function(int) onDelete;
  final Function(int, bool) onToggle;
  final Function(int) onEditTodo;

  const TodoListWidget({
    super.key,
    required this.todos,
    required this.onDelete,
    required this.onToggle,
    required this.onEditTodo,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTodos = todos.toList()
      ..sort((a, b) {
        if (a['completed'] == b['completed']) return 0;
        return a['completed'] ? 1 : -1;
      });

    return ListView.builder(
      itemCount: sortedTodos.length,
      itemBuilder: (context, index) {
        final item = sortedTodos[index];
        final DateTime date = todos[index]['date'];
        final bool isDone = item['completed'] ?? false;

        return Dismissible(
          key: Key(todos[index]['date'].toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete),
          ),
          onDismissed: (direction) {
            final originalIndex = todos.indexOf(
              item,
            ); // indexOf ищет в todos первый элемент и возвращает его индекс, иначе было бы неверное удаление
            onDelete(originalIndex);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: ListTile(
              leading: Checkbox(
                value: isDone,
                onChanged: (bool? newValue) {
                  final originalIndex = todos.indexOf(item);
                  onToggle(originalIndex, newValue ?? false);
                },
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : null,
                ),
              ),
              onTap: () {
                onEditTodo(todos.indexOf(item));
              },
              subtitle: Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              ),
            ),
          ),
        );
      },
    );
  }
}
