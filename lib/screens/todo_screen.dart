import 'package:flutter/material.dart';
import 'package:todo_test/services/todo_service.dart';
import '../widgets/todo_input_widget.dart'; // Виджет ввода текста в поле ввода задачи
import '../widgets/todo_list_widget.dart'; // Виджет хранения задач
import '../services/todo_db.dart';
import 'archive_screen.dart';

enum TodoFilter { all, active, completed }

// Виджет с сохранением состояния поля планера задач
class TodoScreen extends StatefulWidget {
  final TodoService todoService; // Принимаем сервис
  const TodoScreen({super.key, required this.todoService});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  TodoFilter _currentFilter =
      TodoFilter.all; // по умолчанию фильтр на всех задачах
  final TextEditingController _controller = TextEditingController();
  DateTime? _tempSelectedDate;
  final Set<int> _selectedIds = {};

  // Метод выделения/снятия выделения
  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id); // Если уже выделено - убираем
      } else {
        _selectedIds.add(id); // Если нет - добавляем
      }
    });
  }

  // Сброс выделения (для кнопки крестика)
  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  // Метод открытия календаря
  Future<void> _pickDate({TodoDb? todo}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          todo?.date ??
          DateTime.now(), // Если задача передана — открываем ее дату. Если нет — открываем сегодня.
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );

    if (pickedDate != null) {
      if (todo != null) {
        widget.todoService.updateTodo(
          todo.id,
          todo.title,
          pickedDate,
          todo.priority,
        );
      } else {
        setState(() {
          _tempSelectedDate = pickedDate; // Сохраняем выбор
        });
      }
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
                  onAddPressed: (prio) {
                    final newTodo = TodoDb(
                      title: _controller.text,
                      date: _tempSelectedDate ?? DateTime.now(),
                      completed: false,
                      priorityIndex: prio.index,
                    );
                    widget.todoService.addTodo(newTodo);
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
  void _showEditSheet(TodoDb todo) {
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
                  initialPriority: todo.priority,
                  onAddPressed: (prio) {
                    widget.todoService.updateTodo(
                      todo.id,
                      _controller.text,
                      _tempSelectedDate ?? DateTime.now(),
                      prio,
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
        builder: (context) => ArchiveScreen(todoService: widget.todoService),
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
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Меню планера',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Архив'),
              onTap: () {
                Navigator.pop(context);
                _openTrashScreen();
              },
            ),
          ],
        ),
      ),
      appBar: _selectedIds.isNotEmpty
          ? AppBar(
              leading: IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              ),
              title: Text('Выбрано: ${_selectedIds.length}'),

              actions: [
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () {
                    widget.todoService.archiveMultiple(_selectedIds);
                    _clearSelection(); // Сбрасываем выделение после действия
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {
                    widget.todoService.deleteMultiplyPermanetly(_selectedIds);
                    _clearSelection();
                  },
                ),
              ],
            )
          : AppBar(
              title: const Text('Планер дня :)'),
              actions: [
                IconButton(
                  onPressed: _openTrashScreen,
                  icon: const Icon(Icons.archive_outlined),
                ),
              ],
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: SegmentedButton(
              segments: const [
                ButtonSegment<TodoFilter>(
                  value: TodoFilter.all,
                  label: Text("Все"),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment<TodoFilter>(
                  value: TodoFilter.active,
                  label: Text("Активно"),
                  icon: Icon(Icons.circle_outlined),
                ),
                ButtonSegment<TodoFilter>(
                  value: TodoFilter.completed,
                  label: Text("Готово"),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: <TodoFilter>{_currentFilter},
              onSelectionChanged: (Set<TodoFilter> newSelection) {
                setState(() {
                  _currentFilter = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.todoService,
              builder: (context, child) {
                final currentTodos = widget.todoService.todos;
                List<TodoDb> filteredTodos = [];
                if (_currentFilter == TodoFilter.all) {
                  filteredTodos = currentTodos;
                } else if (_currentFilter == TodoFilter.active) {
                  filteredTodos = currentTodos
                      .where((todo) => todo.completed == false)
                      .toList();
                } else if (_currentFilter == TodoFilter.completed) {
                  filteredTodos = currentTodos
                      .where((todo) => todo.completed == true)
                      .toList();
                }
                if (filteredTodos.isEmpty) {
                  return const Center(child: Text("Задач нет"));
                }
                return TodoListWidget(
                  todos: filteredTodos,
                  onDelete: (id) => widget.todoService.moveToTrash(id),
                  onToggle: (id) => widget.todoService.toggleTodo(id),
                  onEditTodo: _showEditSheet,
                  onDeleteForever: (id) =>
                      widget.todoService.deletePermanently(id),
                  onChangeDate: (todo) => _pickDate(todo: todo),
                  selectedIds: _selectedIds,
                  onSelect: _toggleSelection,
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
