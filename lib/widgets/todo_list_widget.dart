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
  final Function(Todo) onChangeDate;
  final Set<String> selectedIds;
  final Function(String) onSelect;

  const TodoListWidget({
    super.key,
    required this.todos,
    required this.onDelete,
    required this.onToggle,
    required this.onEditTodo,
    required this.onDeleteForever,
    required this.onChangeDate,
    required this.selectedIds,
    required this.onSelect,
  });
  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.amber;
      case TodoPriority.low:
        return Colors.green;
    }
  }

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
        final bool isSelected = selectedIds.contains(item.id);
        final bool isSelectionMode = selectedIds.isNotEmpty;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          clipBehavior: Clip.hardEdge,
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: Slidable(
            key: ValueKey(item.id),
            startActionPane: ActionPane(
              extentRatio: 0.5,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => {onEditTodo(item)},
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                ),
                SlidableAction(
                  onPressed: (context) => onChangeDate(item),
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            ),
            endActionPane: ActionPane(
              extentRatio: 0.5,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => onDelete(item.id),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  icon: Icons.archive_outlined,
                ),
                SlidableAction(
                  onPressed: (context) => onDeleteForever(item.id),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                ),
              ],
            ),
            child: ListTile(
              onLongPress: () => onSelect(item.id),
              leading: Checkbox(
                activeColor: _getPriorityColor(item.priority),
                side: BorderSide(
                  color: _getPriorityColor(item.priority),
                  width: 2,
                ),
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
              onTap: () => {
                if (isSelectionMode)
                  {onSelect(item.id)}
                else
                  {onEditTodo(item)},
              },
              subtitle: Text(date.toFriendlyString()),
            ),
          ),
        );
      },
    );
  }
}
