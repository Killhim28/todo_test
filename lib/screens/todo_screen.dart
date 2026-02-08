import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Для работы с JSON

import '../widgets/todo_input_widget.dart'; // Виджет ввода текста в поле ввода задачи
import '../widgets/todo_list_widget.dart'; // Виджет хранения задач
import '../models/todo_class.dart'; // Класс Todo

// Виджет с сохранением состояния поля планера задач
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Todo> _todos = [];
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
        _todos.add(
          Todo(
            id: DateTime.now().millisecondsSinceEpoch
                .toString(), // Добавляем уникальный id
            title: _controller.text,
            date: _tempSelectedDate ?? DateTime.now(),
          ),
        );
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
    _controller.text = _todos[index].title;
    _tempSelectedDate =
        _todos[index].date; // Загружаем старую дату тоже (если она есть)

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
                      // Замена объекта Todo c новым полем title
                      setState(() {
                        _todos[index].copyWith(
                          completed: _todos[index]
                              .completed, // Сохранение старого статуса
                        );
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
      _todos[index] = _todos[index].copyWith(
        completed: value,
      ); // Обновляем словарь todos состояния
    });
    _saveTodos(); // Сохраняем после добавления
  }

  // Метод сохранения данных
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Вызываем .toJson() у каждого объекта
    List<String> todosJson = _todos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList();
    await prefs.setStringList('todos', todosJson);
  }

  // Метод загрузки данных
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todosJson = prefs.getStringList('todos');
    if (todosJson != null) {
      setState(() {
        _todos.clear();
        // Превращаем строки обратно в объекты Todo
        _todos.addAll(
          todosJson.map((str) => Todo.fromJson(jsonDecode(str))).toList(),
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
