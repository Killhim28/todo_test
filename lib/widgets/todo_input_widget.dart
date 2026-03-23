import 'package:flutter/material.dart';
import '../models/todo_class.dart';

// Виджет ввода текста в поле ввода задачи
class TodoInputWidget extends StatefulWidget {
  final TextEditingController controller;

  final Function(TodoPriority priority, String? imagePath) onAddPressed;
  final VoidCallback onDatePressed;
  final TodoPriority initialPriority;
  final String? initialmagePath;

  const TodoInputWidget({
    super.key,
    required this.controller,
    required this.onAddPressed,
    required this.onDatePressed,
    this.initialPriority = TodoPriority.low,
    required this.initialmagePath,
  });

  @override
  State<TodoInputWidget> createState() => _TodoInputWidgetState();
}

class _TodoInputWidgetState extends State<TodoInputWidget> {
  String? _attachedImagePath;
  late TodoPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    // При открытии шторки берем цвет, который нам передали снаружи
    _selectedPriority = widget.initialPriority;
    _attachedImagePath = widget.initialmagePath;
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
                widget.onAddPressed(_selectedPriority, _attachedImagePath);
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
                        color: getPriorityColor(_selectedPriority),
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
                                    color: getPriorityColor(TodoPriority.low),
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
                                    color: getPriorityColor(
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
                                    color: getPriorityColor(TodoPriority.high),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Высокий приоритет'),
                                ],
                              ),
                            ),
                          ],
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onDatePressed,
                      icon: Icon(Icons.calendar_month),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => widget.onAddPressed(
                        _selectedPriority,
                        _attachedImagePath,
                      ),
                      icon: Icon(Icons.send),
                    ),
                  ],
                ),
                hintText: 'Новая задача',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
