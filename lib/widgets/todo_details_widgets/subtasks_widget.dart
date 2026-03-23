import 'package:flutter/material.dart';
import 'package:todo_test/services/todo_db.dart';
import '../../services/todo_service.dart';

class SubtasksWidget extends StatefulWidget {
  final TodoDb subtask;
  final TodoService todoService;
  const SubtasksWidget({
    super.key,
    required this.subtask,
    required this.todoService,
  });

  @override
  State<SubtasksWidget> createState() => _SubtasksWidgetState();
}

class _SubtasksWidgetState extends State<SubtasksWidget> {
  final TextEditingController _controller = TextEditingController();

  // Добавляем FocusNode, чтобы управлять клавиатурой
  final FocusNode _focusNode = FocusNode();

  // показываем ли мы сейчас строку ввода или просто кнопку "+"
  bool _isAdding = false;
  // развернут ли список подзадач?
  bool _isExpanded = false;

  void _saveSubtask() {
    final text = _controller.text
        .trim(); // Обрезка по краем, также лишние символы
    if (text.isNotEmpty) {
      final newSubtask = SubtaskDb(title: text);

      // После сохранения прячем поле ввода и очищаем текст
      setState(() {
        widget.subtask.subtasks.add(newSubtask);
      });
    }
    widget.todoService.saveTodo(widget.subtask); // Сохранение в БД
    setState(() {
      _isAdding = false;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    // Очистка контроллеров чтобы не было утечки памяти при закрытии экрана подзадач
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = widget.subtask.subtasks
        .where((subtask) => subtask.isDone)
        .length;
    final int totalCount = widget.subtask.subtasks.length;
    return Column(
      children: [
        // Кнопка скрытия/показа подзадач со стрелочкой
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Переключаем флаг
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_right : Icons.list,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                const Text('Подзадачи', style: TextStyle(fontSize: 16)),
                Spacer(),
                Text(
                  '$completedCount из $totalCount выполнено',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        // Блок подзадач (показываем, только если _isExpanded == true)
        if (_isExpanded)
          Padding(
            // Сдвигаем весь блок подзадач вправо.
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                // 1. Вывод готовых подзадач
                // Используем asMap().entries, чтобы знать индекс каждой подзадачи для удаления
                ...widget.subtask.subtasks.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final SubtaskDb subtask = entry.value;

                  return Row(
                    key: ObjectKey(
                      subtask,
                    ), // Без ключа удалялись бы неверные подзадачи (была бы проблема с индексами)
                    children: [
                      Checkbox(
                        value: subtask.isDone,
                        activeColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (bool? newValue) {
                          setState(() {
                            subtask.isDone = newValue ?? false;
                          });
                          widget.todoService.updateSubtask(subtask);
                        },
                      ),

                      // Редактируемый текст подзадачи
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              subtask.title, // Вставляем текущий текст
                          decoration: const InputDecoration(
                            border: InputBorder.none, // Прячем рамки
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            decoration: subtask.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: subtask.isDone ? Colors.grey : null,
                          ),
                          onChanged: (newText) {
                            // обновляем текст в памяти при каждом нажатии клавиши
                            subtask.title = newText;
                          },
                          onFieldSubmitted: (_) {
                            widget.todoService.saveTodo(widget.subtask);
                          },
                        ),
                      ),

                      // Кнопка удаления подзадачи
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          final subtaskToDelete =
                              widget.subtask.subtasks[index];
                          setState(() {
                            widget.subtask.subtasks.removeAt(index);
                            widget.subtask.subtasks.applyToDb();
                          });
                          widget.todoService.saveTodo(widget.subtask);
                          if (subtaskToDelete.id != 0) {
                            widget.todoService.deleteSubtask(
                              subtaskToDelete.id,
                            );
                          }
                        },
                      ),
                    ],
                  );
                }),

                // 2. Строка добавления (Либо невидимое поле ввода, либо кнопка "+")
                if (_isAdding)
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.check_box_outline_blank,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Что нужно сделать?',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _saveSubtask(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.blue),
                        onPressed: _saveSubtask,
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAdding = true; // Показываем поле ввода
                      });
                      // Небольшая задержка, чтобы UI успел перерисоваться
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _focusNode
                            .requestFocus(); // принудительно открывает клавиатуру и ставит курсор в наше текстовое поле.
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.grey[600], size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Добавить подзадачу',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
