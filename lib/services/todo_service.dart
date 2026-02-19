import 'package:flutter/material.dart';
import '../models/todo_class.dart';
import 'dart:convert'; // Для работы с JSON
import 'package:shared_preferences/shared_preferences.dart';

class TodoService extends ChangeNotifier {
  final List<Todo> _todos = []; // Приватный список (чтобы не поломали снаружи)
  final List<Todo> _deletedTodos = []; // Приватный список удаленных задач
  List<Todo> get todos => _todos; // Геттер для чтения списка
  List<Todo> get deletedTodos => _deletedTodos; // Геттер для чтения списка

  // Метод добавления задачи
  void addTodo(String title, DateTime date) {
    if (title.isNotEmpty) {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        date: date,
      );
      _todos.add(newTodo);
      // Сохраняем после удаления
      _saveTodos();
      notifyListeners(); // Замена setState
    }
  }

  // Метод удаления задачи
  void removeTodo(String id) {
    final index = _todos.indexWhere((item) => item.id == id);
    if (index != -1) {
      final removedItem = _todos[index];
      _todos.removeAt(index);
      _deletedTodos.add(removedItem);
      // Сохраняем после удаления
      _saveTodos();
      _saveDeletedtodos();
      notifyListeners();
    }
  }

  // Метод перманентного удаления из корзины
  void deletePermanently(String id) {
    _deletedTodos.removeWhere((item) => item.id == id);
    _saveDeletedtodos();
    notifyListeners();
  }

  // Метод востановления задачи из корзины
  void restoreTodo(Todo todo) {
    _deletedTodos.removeWhere((item) => item.id == todo.id);
    final bool alreadyExists = _todos.any(
      (item) => item.id == todo.id,
    ); // Если задача уже существует, восстанавлиаем ее
    if (!alreadyExists) {
      _todos.add(todo);
    }
    _saveTodos();
    _saveDeletedtodos();
    notifyListeners();
  }

  // Редактирование задачи
  void toggleTodo(String id, bool value) {
    final index = _todos.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(completed: value);
      _saveTodos(); // Сохраняем после добавления
      notifyListeners();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Вызываем .toJson() у каждого объекта
    List<String> todosJson = _todos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList();
    await prefs.setStringList('todos', todosJson);
  }

  // Метод сохранения данных корзины
  Future<void> _saveDeletedtodos() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> deletedJson = _deletedTodos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList();
    await prefs.setStringList('deleted_todos', deletedJson);
  }

  // Метод загрузки данных
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todosJson = prefs.getStringList('todos');
    if (todosJson != null) {
      _todos.clear();
      // Превращаем строки обратно в объекты Todo
      _todos.addAll(
        todosJson.map((str) => Todo.fromJson(jsonDecode(str))).toList(),
      );
      notifyListeners();
    }
    final List<String>? deletedJson = prefs.getStringList('deleted_todos');
    if (deletedJson != null) {
      _deletedTodos.clear();
      _deletedTodos.addAll(
        deletedJson.map((str) => Todo.fromJson(jsonDecode(str))).toList(),
      );
      notifyListeners();
    }
  }

  // Метод обновления задачи (для редактирования)
  void updateTodo(String id, String newTitle, DateTime newDate) {
    final index = _todos.indexWhere((element) => element.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(title: newTitle, date: newDate);
      _saveTodos();
      notifyListeners();
    }
  }
}
