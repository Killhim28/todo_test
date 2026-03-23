import 'package:flutter/material.dart';

enum TodoPriority { low, medium, high }

class Todo {
  final String
  id; // Уникальный ID (чтобы точно знать, какую задачу редактировать)
  final String title; // Название
  final DateTime date; // Дата
  final bool completed;
  final TodoPriority priority;

  Todo({
    required this.id,
    required this.title,
    required this.date,
    this.completed = false,
    this.priority = TodoPriority.low,
  });

  Todo copyWith({
    String? id,
    String? title,
    DateTime? date,
    bool? completed,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
    );
  }
}

Color getPriorityColor(TodoPriority priority) {
  switch (priority) {
    case TodoPriority.high:
      return Colors.red;
    case TodoPriority.medium:
      return Colors.amber;
    case TodoPriority.low:
      return Colors.green;
  }
}

// Вспомогательный метод для текста
String getPriorityText(TodoPriority priority) {
  switch (priority) {
    case TodoPriority.high:
      return 'Высокий приоритет';
    case TodoPriority.medium:
      return 'Средний приоритет';
    case TodoPriority.low:
      return 'Низкий приоритет';
  }
}
