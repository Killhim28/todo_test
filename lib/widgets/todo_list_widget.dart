import 'package:flutter/material.dart';
import '../models/todo_class.dart'; // Класс Todo

// Виджет хранения задач
class TodoListWidget extends StatelessWidget {
  final List<Todo> todos;
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
        if (a.completed != b.completed) {
          return a.completed ? 1 : -1; // Cортировка выполенных задач вниз
        }
        return b.date.compareTo(
          a.date,
        ); // Если статус выполнения одинаковый, сортируем по дате
      });

    return ListView.builder(
      itemCount: sortedTodos.length,
      itemBuilder: (context, index) {
        final item = sortedTodos[index];
        final DateTime date = item.date; // Нужно брать дату по новому индексу
        final bool isDone = item.completed;

        return Dismissible(
          key: Key(item.id),
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
                item.title,
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
