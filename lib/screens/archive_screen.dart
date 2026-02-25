import 'package:flutter/material.dart';
import '../services/todo_service.dart';

// Замена на Stateless, так как состояние теперь в Сервисе
class ArchiveScreen extends StatefulWidget {
  final TodoService todoService;

  const ArchiveScreen({super.key, required this.todoService});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final Set<String> _selectedIds = {};
  // Метод выделения/снятия выделения
  void _toggleSelection(String id) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIds.isNotEmpty
          ? AppBar(
              leading: IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              ),
              title: Text('Выбрано: ${_selectedIds.length}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    widget.todoService.restoreTodoMultiple(_selectedIds);
                    _clearSelection();
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
          : AppBar(title: const Text("Архив")),
      // ListenableBuilder следит за изменениями в сервисе
      body: ListenableBuilder(
        listenable: widget.todoService,
        builder: (context, child) {
          // Берем список удаленных из сервиса
          final deletedTodos = widget.todoService.deletedTodos;

          if (deletedTodos.isEmpty) {
            return const Center(child: Text("Архив пуст"));
          }
          return ListView.builder(
            itemCount: deletedTodos.length,
            itemBuilder: (context, index) {
              final todo = deletedTodos[index];
              final bool isSelected = _selectedIds.contains(todo.id);
              
              return Card(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  onTap: () => {_toggleSelection(todo.id)},
                  onLongPress: () => _toggleSelection(todo.id),
                  title: Text(todo.title),
                  subtitle: const Text("Удалено"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
