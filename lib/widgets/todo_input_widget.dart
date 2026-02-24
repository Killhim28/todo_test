import 'package:flutter/material.dart';
import '../models/todo_class.dart';

// Виджет ввода текста в поле ввода задачи
class TodoInputWidget extends StatefulWidget {
  final TextEditingController controller;

  final Function(TodoPriority priority) onAddPressed;
  final VoidCallback onDatePressed;
  final TodoPriority initialPriority;

  const TodoInputWidget({
    super.key,
    required this.controller,
    required this.onAddPressed,
    required this.onDatePressed,
    this.initialPriority = TodoPriority.low,
  });

  @override
  State<TodoInputWidget> createState() => _TodoInputWidgetState();
}

class _TodoInputWidgetState extends State<TodoInputWidget> {
  late TodoPriority _selectedPriority;
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
  void initState() {
    super.initState();
    // При открытии шторки берем цвет, который нам передали снаружи
    _selectedPriority = widget.initialPriority;
  }

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
                widget.onAddPressed(_selectedPriority);
              },
              controller: widget.controller,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Ограничение размера, займет столько места сколько потребуется
                  children: [
                    PopupMenuButton<TodoPriority>(
                      initialValue: _selectedPriority,
                      tooltip: "Выбрать приоритет",
                      icon: Icon(
                        Icons.error_outline,
                        color: _getPriorityColor(_selectedPriority),
                      ),
                      onSelected: (TodoPriority newPriority) {
                        setState(() {
                          _selectedPriority = newPriority;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<TodoPriority>>[
                            CheckedPopupMenuItem<TodoPriority>(
                              value: TodoPriority.low,
                              checked: _selectedPriority == TodoPriority.low,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: _getPriorityColor(TodoPriority.low),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Низкий приоритет'),
                                ],
                              ),
                            ),
                            CheckedPopupMenuItem<TodoPriority>(
                              value: TodoPriority.medium,
                              checked: _selectedPriority == TodoPriority.medium,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: _getPriorityColor(
                                      TodoPriority.medium,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Средний приоритет'),
                                ],
                              ),
                            ),
                            CheckedPopupMenuItem<TodoPriority>(
                              value: TodoPriority.high,
                              checked: _selectedPriority == TodoPriority.high,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: _getPriorityColor(TodoPriority.high),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Высокий приоритет'),
                                ],
                              ),
                            ),
                          ],
                    ),
                    IconButton(
                      onPressed: widget.onDatePressed,
                      icon: Icon(Icons.calendar_month),
                    ),
                    IconButton(
                      onPressed: () => widget.onAddPressed(_selectedPriority),
                      icon: Icon(Icons.send),
                    ),
                  ],
                ),
                hintText: 'Новая задача',
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
