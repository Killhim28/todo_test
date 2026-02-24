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

  // Превращаем JSON (Map) в объект Todo
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id:
          json['id'] ??
          DateTime.now().toString(), // Если id нет в старых данных, генерируем
      title: json['title'],
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      priority: json['priority'] != null
          ? TodoPriority.values.firstWhere(
              (e) => e.name == json['priority'],
              orElse: () => TodoPriority.low,
            )
          : TodoPriority.low,
    );
  }
  // Превращаем объект Todo в JSON (Map) для сохранения
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date
          .toIso8601String(), // Дату нельзя сохранить как есть (может быть проблема с форматированием), превращаем в строку ISO8601
      'completed': completed,
      'priority': priority.name,
    };
  }
}
