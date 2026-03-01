import 'package:flutter/material.dart';
import 'package:todo_test/main.dart';
import 'package:todo_test/objectbox.g.dart';
import 'package:todo_test/services/todo_db.dart';
import '../models/todo_class.dart';

class TodoService extends ChangeNotifier {
  List<TodoDb> _deletedTodos = [];
  List<TodoDb> _todos = [];

  List<TodoDb> get todos => _todos;
  List<TodoDb> get deletedTodos => _deletedTodos;

  TodoService() {
    loadTodos(); // Загружаем данные из БД сразу, чтобы было отображение при первом запуске
  }

  // выгружает данные из БД
  void loadTodos() {
    final activeQuery = objectbox.todoBox
        .query(TodoDb_.isDeleted.equals(false))
        .build();
    _todos = activeQuery.find();
    activeQuery.close();

    final trashQuery = objectbox.todoBox
        .query(TodoDb_.isDeleted.equals(true))
        .build();
    _deletedTodos = trashQuery.find();
    trashQuery.close();

    notifyListeners();
  }

  void addTodo(TodoDb newTodo) {
    objectbox.todoBox.put(newTodo);
    loadTodos();
  }

  void moveToTrash(int id) {
    final todo = objectbox.todoBox.get(id);
    if (todo != null) {
      todo.isDeleted = true;
      objectbox.todoBox.put(todo);
      loadTodos();
    }
  }

  void restoreTodo(int id) {
    final todo = objectbox.todoBox.get(id);
    if (todo != null) {
      todo.isDeleted = false;
      objectbox.todoBox.put(todo);
      loadTodos();
    }
  }

  void deletePermanently(int id) {
    objectbox.todoBox.remove(id); // Удаляем из БД навсегда
    loadTodos();
  }

  void toggleTodo(int id) {
    final todo = objectbox.todoBox.get(id);
    if (todo != null) {
      todo.completed = !todo.completed;
      objectbox.todoBox.put(todo);
      loadTodos();
    }
  }

  void updateTodo(
    int id,
    String newTitle,
    DateTime newDate,
    TodoPriority newPriority,
  ) {
    final todo = objectbox.todoBox.get(id);
    if (todo != null) {
      todo.title = newTitle;
      todo.date = newDate;
      todo.priority = newPriority;
      objectbox.todoBox.put(todo);
      loadTodos();
    }
  }

  // МНОЖЕСТВЕННЫЕ ДЕЙСТВИЯ

  void archiveMultiple(Set<int> ids) {
    final itemsToArchive = objectbox.todoBox.getMany(ids.toList());
    for (var item in itemsToArchive) {
      if (item != null) item.isDeleted = true;
    }
    objectbox.todoBox.putMany(itemsToArchive.whereType<TodoDb>().toList());
    loadTodos();
  }

  void restoreTodoMultiple(Set<int> ids) {
    final itemsToRestore = objectbox.todoBox.getMany(ids.toList());
    for (var item in itemsToRestore) {
      if (item != null) item.isDeleted = false;
    }
    objectbox.todoBox.putMany(itemsToRestore.whereType<TodoDb>().toList());
    loadTodos();
  }

  void deleteMultiplyPermanetly(Set<int> ids) {
    objectbox.todoBox.removeMany(ids.toList());
    loadTodos();
  }
}
