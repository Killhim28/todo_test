import 'package:flutter/material.dart';
import 'package:todo_test/services/todo_service.dart';
import 'package:todo_test/widgets/todo_details_widgets/date_task_widget.dart';
import 'package:todo_test/widgets/todo_details_widgets/image_pick_widget.dart';
import 'package:todo_test/widgets/todo_details_widgets/one_task_widget.dart';
import 'package:todo_test/widgets/todo_details_widgets/priority_widget.dart';
import 'package:todo_test/widgets/todo_details_widgets/subtasks_widget.dart';
import '../main.dart';

class TaskDetailScreen extends StatelessWidget {
  final int taskId;
  final TodoService todoService;
  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.todoService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактирование - детали задачи #$taskId')),
      body: ListenableBuilder(
        listenable: todoService,
        builder: (context, child) {
          final task = objectbox.todoBox.get(taskId);
          if (task == null) {
            return const Center(child: Text('Задача не найдена'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OneTaskWidget(
                // Виджет вывода одной задачи
                todo: task,
                onToggle: (id) => todoService.toggleTodo(id),
                onSave: (updatedTask) {
                  todoService.saveTodo(task);
                },
              ),
              // Виджет подзадач
              SubtasksWidget(
                subtask: task,
                todoService:
                    todoService, // Передаем сервис для сохранения в базу
              ),
              PriorityWidget(task: task, todoService: todoService),
              DateTaskWidget(task: task, todoService: todoService),
              ImagePickWidget(task: task, todoService: todoService),
            ],
          );
        },
      ),
    );
  }
}
