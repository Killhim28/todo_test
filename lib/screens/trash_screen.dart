import 'package:flutter/material.dart';
import '../models/todo_class.dart';
// import '../widgets/todo_list_widget.dart';

class TrashScreen extends StatefulWidget {
  final List<Todo> deletedTodos;
  final Function(Todo) onRestore;
  final Function(String) onDeleteForever;

  const TrashScreen({
    super.key,
    required this.deletedTodos,
    required this.onRestore,
    required this.onDeleteForever,
  });

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Корзина")),
      body: widget.deletedTodos.isEmpty
          ? const Center(child: Text("Корзина пуста"))
          : ListView.builder(
              itemCount: widget.deletedTodos.length,
              itemBuilder: (context, index) {
                final todo = widget.deletedTodos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text("Удалено"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.onRestore(todo);
                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Задача "${todo.title}" восстановлена',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(Icons.restore, color: Colors.green),
                      ),

                      IconButton(
                        onPressed: () {
                          widget.onDeleteForever(todo.id);
                          setState(() {});
                        },
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
