import 'package:flutter/material.dart';
import 'package:todo_test/services/todo_db.dart';
import '../../models/todo_class.dart'; // Класс Todo

class OneTaskWidget extends StatefulWidget {
  final TodoDb todo;
  final Function(int) onToggle;
  final Function(TodoDb) onSave; // передаем всю задачу целиком для сохранения

  const OneTaskWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onSave,
  });

  @override
  State<OneTaskWidget> createState() => _OneTaskWidgetState();
}

class _OneTaskWidgetState extends State<OneTaskWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Заполняем контроллеры текущими данными из базы
    _titleController = TextEditingController(text: widget.todo.title);
    _descController = TextEditingController(
      text: widget.todo.description ?? '',
    );

    // если поле заголовка потеряло фокус - сохраняем
    _titleFocus.addListener(() {
      if (!_titleFocus.hasFocus) {
        _saveData();
      }
    });

    _descFocus.addListener(() {
      if (!_descFocus.hasFocus) {
        _saveData();
      }
    });
  }

  void _saveData() {
    // Обновляем данные в объекте задачи
    widget.todo.title = _titleController.text.trim();
    widget.todo.description = _descController.text.trim();
    widget.onSave(widget.todo);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.todo.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // 1. СТРОКА С ЧЕКБОКСОМ И ЗАГОЛОВКОМ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: getPriorityColor(widget.todo.priority),
                side: BorderSide(
                  color: getPriorityColor(widget.todo.priority),
                  width: 2,
                ),
                value: isDone,
                onChanged: (bool? newValue) {
                  widget.onToggle(widget.todo.id);
                },
              ),
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus, // Подключаем слушателя
                  textInputAction: TextInputAction
                      .next, // Меняет кнопку "Enter" на клавиатуре на "Далее"
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 12),
                  ),
                  onFieldSubmitted: (_) {
                    // Перекидывает курсор в поле описания!
                    FocusScope.of(context).requestFocus(_descFocus);
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus
                        ?.unfocus(); // Убирает фокус при тапе мимо заголовка
                  },
                ),
              ),
            ],
          ),

          // 2. БЕСКОНЕЧНОЕ ПОЛЕ ОПИСАНИЯ
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus
                    ?.unfocus(); // Убираем фокус при тапе мимо
              },
              controller: _descController,
              focusNode: _descFocus,
              maxLines: null, // Делает поле бесконечным (растет вниз)
              keyboardType: TextInputType
                  .multiline, // Разрешает переносы строк внутри описания
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Описание задачи',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
