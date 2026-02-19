import 'package:flutter/material.dart';

import 'package:todo_test/services/todo_service.dart';

import '../widgets/todo_input_widget.dart'; // Виджет ввода текста в поле ввода задачи
import '../widgets/todo_list_widget.dart'; // Виджет хранения задач
import '../models/todo_class.dart'; // Класс Todo
import '../screens/trash_screen.dart';

// Виджет с сохранением состояния поля планера задач
class TodoScreen extends StatefulWidget {
  final TodoService todoService; // Принимаем сервис
  const TodoScreen({super.key, required this.todoService});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _tempSelectedDate;

  // Метод открытия календаря
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );

    if (pickedDate != null) {
      setState(() {
        _tempSelectedDate = pickedDate; // Сохраняем выбор
      });
    }
  }

  // Метод шторки
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Отступ снизу равен высоте клавиатуры
          ),
          child: SizedBox(
            height: 100,
            child: Center(
              child: SingleChildScrollView(
                child: TodoInputWidget(
                  controller: _controller,
                  onAddPressed: () {
                    widget.todoService.addTodo(
                      _controller.text,
                      _tempSelectedDate ?? DateTime.now(),
                    );
                    _controller.clear();
                    Navigator.pop(context);
                  },
                  onDatePressed: _pickDate,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Метод редактирования задач
  void _showEditSheet(Todo todo) {
    _controller.text = todo.title;
    _tempSelectedDate = todo.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Отступ снизу равен высоте клавиатуры
          ),
          child: SizedBox(
            height: 100,
            child: Center(
              child: SingleChildScrollView(
                child: TodoInputWidget(
                  controller: _controller,
                  onAddPressed: () {
                    widget.todoService.updateTodo(
                      todo.id,
                      _controller.text,
                      _tempSelectedDate ?? DateTime.now(),
                    );
                    _controller.clear();
                    Navigator.pop(context);
                  },
                  onDatePressed: _pickDate,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Метод открытия экрана
  void _openTrashScreen() {
    Navigator.push(
      context, // "откуда" мы переходим (с текущего экрана)
      MaterialPageRoute(
        builder: (context) => TrashScreen(todoService: widget.todoService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Меню планера',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Корзина'),
              onTap: () {
                Navigator.pop(context);
                _openTrashScreen();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Планер дня :)'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TrashScreen(todoService: widget.todoService),
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.todoService,
        builder: (context, child) {
          final currentTodos = widget.todoService.todos;
          if (currentTodos.isEmpty) {
            return const Center(child: Text("Задач нет"));
          }
          return TodoListWidget(
            todos: currentTodos,
            onDelete: (id) => widget.todoService.removeTodo(id),
            onToggle: (id, val) => widget.todoService.toggleTodo(id, val),
            onEditTodo: _showEditSheet,
            onDeleteForever: (id) => widget.todoService.deletePermanently(id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
