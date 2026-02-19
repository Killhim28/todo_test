import 'package:flutter/material.dart';
import '../services/todo_service.dart';

// Замена на Stateless, так как состояние теперь в Сервисе
class TrashScreen extends StatelessWidget {
  final TodoService todoService;

  const TrashScreen({super.key, required this.todoService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Корзина")),
      // ListenableBuilder следит за изменениями в сервисе
      body: ListenableBuilder(
        listenable: todoService,
        builder: (context, child) {
          // Берем список удаленных прямо из сервиса
          final deletedTodos = todoService.deletedTodos;

          if (deletedTodos.isEmpty) {
            return const Center(child: Text("Корзина пуста"));
          }

          return ListView.builder(
            itemCount: deletedTodos.length,
            itemBuilder: (context, index) {
              final todo = deletedTodos[index];

              return ListTile(
                title: Text(todo.title),
                subtitle: const Text("Удалено"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore, color: Colors.green),
                      onPressed: () {
                        todoService.restoreTodo(todo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Задача "${todo.title}" восстановлена',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        todoService.deletePermanently(todo.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
