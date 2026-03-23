import 'package:flutter/material.dart';
import 'package:todo_test/models/todo_class.dart';
import 'package:todo_test/services/todo_db.dart';
import 'package:todo_test/services/todo_service.dart';

class PriorityWidget extends StatelessWidget {
  final TodoDb task;
  final TodoService todoService;

  const PriorityWidget({
    super.key,
    required this.task,
    required this.todoService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<TodoPriority>(
            initialValue: task.priority,
            tooltip: 'Изменить приоритет',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: getPriorityColor(task.priority),
                  ),
                  const SizedBox(width: 8),
                  Text("Приоритет", style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(
                    getPriorityText(task.priority),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            onSelected: (TodoPriority newPriority) {
              task.priority = newPriority;
              todoService.saveTodo(task);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<TodoPriority>>[
                  CheckedPopupMenuItem<TodoPriority>(
                    value: TodoPriority.low,
                    checked: task.priority == TodoPriority.low,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: getPriorityColor(TodoPriority.low),
                        ),
                        const SizedBox(width: 10),
                        const Text("Низкий приоритет"),
                      ],
                    ),
                  ),
                  CheckedPopupMenuItem<TodoPriority>(
                    value: TodoPriority.medium,
                    checked: task.priority == TodoPriority.medium,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: getPriorityColor(TodoPriority.medium),
                        ),
                        const SizedBox(width: 10),
                        const Text('Средний приоритет'),
                      ],
                    ),
                  ),
                  CheckedPopupMenuItem<TodoPriority>(
                    value: TodoPriority.high,
                    checked: task.priority == TodoPriority.high,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: getPriorityColor(TodoPriority.high),
                        ),
                        const SizedBox(width: 10),
                        const Text('Высокий приоритет'),
                      ],
                    ),
                  ),
                ],
          ),
        ),
      ],
    );
  }
}
