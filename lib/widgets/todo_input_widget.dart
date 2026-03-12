import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      print('Пользователь сделал фото');
      final permanentPath = await _saveImagePermanently(image.path);
      setState(() {
        _attachedImagePath =
            permanentPath; // Запоминаем путь в State, чтобы виджет знал, что фото прикреплено
      });
      print('Пользователь сделал фото $_attachedImagePath');
    } else {
      print("Пользователь не сделал фото");
    }
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _saveImagePermanently(String temImagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(temImagePath);
    final savedImagePath = p.join(directory.path, fileName);
    final savedImage = await File(temImagePath).copy(savedImagePath);
    return savedImage.path;
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.amber;
      case TodoPriority.low:
        return Colors.green;
    }
  }

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
          if (_attachedImagePath != null)
            GestureDetector(
              onTap: () {
                _showImageDialog(_attachedImagePath!);
              },
              child: Container(
                width: 58,
                height: 58,
                margin: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_attachedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
                        color: _getPriorityColor(_selectedPriority),
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
                                    color: _getPriorityColor(TodoPriority.low),
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
                                    color: _getPriorityColor(
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
                                    color: _getPriorityColor(TodoPriority.high),
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
                      onPressed: _pickImage,
                      icon: Icon(Icons.camera_alt),
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
