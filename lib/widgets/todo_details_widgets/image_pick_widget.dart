import 'package:flutter/material.dart';
import 'package:todo_test/services/todo_db.dart';
import 'package:todo_test/services/todo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImagePickWidget extends StatefulWidget {
  final TodoDb task;
  final TodoService todoService;

  const ImagePickWidget({
    super.key,
    required this.task,
    required this.todoService,
  });

  @override
  State<ImagePickWidget> createState() => _ImagePickWidgetState();
}

class _ImagePickWidgetState extends State<ImagePickWidget> {
  // Выбор фото (нужно добавить выбор из Галереи или Камеры)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Открываем галерею (можно поменять на ImageSource.camera)
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final permanentPath = await _saveImagePermanently(image.path);

      setState(() {
        widget.task.imagePath = permanentPath; // Сохраняем путь в саму задачу
      });

      widget.todoService.saveTodo(widget.task);
    }
  }

  // Сохранение фото в память телефона
  Future<String> _saveImagePermanently(String tempImagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(tempImagePath);
    final savedImagePath = p.join(directory.path, fileName);
    final savedImage = await File(tempImagePath).copy(savedImagePath);
    return savedImage.path;
  }

  // Полноэкранный просмотр
  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                // Само фото с возможностью зума
                InteractiveViewer(
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
                // Кнопка закрытия просмотра
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Удаление вложения
  void _removeImage() {
    setState(() {
      widget.task.imagePath = null;
    });
    widget.todoService.saveTodo(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.task.imagePath != null;
    return InkWell(
      onTap: hasImage ? null : _pickImage,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('Прикрепить фото', style: TextStyle(fontSize: 16)),
            const Spacer(),
            // Если фото есть - показываем миниатюру
            if (hasImage)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Сама миниатюра, по тапу открывается на весь экран
                  GestureDetector(
                    onTap: () => _showImageDialog(widget.task.imagePath!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.task.imagePath!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _removeImage,
                    padding: EdgeInsets.zero,
                  ),
                ],
              )
            else
              const Text(
                'Добавить фото',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
