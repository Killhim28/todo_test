import 'package:flutter/material.dart';
import 'package:todo_test/extensions/date_extension.dart';
import 'package:todo_test/services/todo_db.dart';
import 'package:todo_test/services/todo_service.dart';

class DateTaskWidget extends StatelessWidget {
  final TodoDb task;
  final TodoService todoService;

  const DateTaskWidget({
    super.key,
    required this.task,
    required this.todoService,
  });

  Future<void> _changeDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task.date,
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );
    if (pickedDate != null) {
      task.date = pickedDate; // меняем дату у задачи
      todoService.saveTodo(task); // Сохраняем в базу
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          _changeDate(context), //  вызываем переданную функцию при тапе
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.calendar_month),
            const SizedBox(width: 8),
            const Text('Дата', style: TextStyle(fontSize: 16)),
            Spacer(),
            Text(
              task.date.toFriendlyString(),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
