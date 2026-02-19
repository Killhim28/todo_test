import 'package:flutter/material.dart';
import '../models/todo_class.dart'; // Класс Todo
import 'package:flutter_slidable/flutter_slidable.dart';
import '../extensions/date_extension.dart';

// Виджет хранения задач
class TodoListWidget extends StatelessWidget {
  final List<Todo> todos;
  final Function(String) onDelete;
  final Function(String, bool) onToggle;
  final Function(Todo) onEditTodo;
  final Function(String) onDeleteForever;

  const TodoListWidget({
    super.key,
    required this.todos,
    required this.onDelete,
    required this.onToggle,
    required this.onEditTodo,
    required this.onDeleteForever,
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

        return Slidable(
          key: ValueKey(item.id),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => {onDelete(item.id)},
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                // label: 'Перенести в корзину',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                  right: Radius.circular(10),
                ),
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => {onEditTodo(item)},
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                // label: 'Редактировать задачу',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                  right: Radius.circular(10),
                ),
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: ListTile(
              leading: Checkbox(
                value: isDone,
                onChanged: (bool? newValue) {
                  onToggle(item.id, newValue ?? false);
                },
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : null,
                ),
              ),
              onTap: () => {onEditTodo(item)},
              subtitle: Text(
                date.toFriendlyString(),
                // '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              ),
            ),
          ),
        );
      },
    );
  }
}
