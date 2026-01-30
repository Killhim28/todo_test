import 'package:flutter/material.dart';

// Виджет ввода текста в поле ввода задачи
class TodoInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddPressed;
  final VoidCallback onDatePressed;

  const TodoInputWidget({
    super.key,
    required this.controller,
    required this.onAddPressed,
    required this.onDatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              onSubmitted: (text) {
                onAddPressed();
              },
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Ограничение размера, займет столько места сколько потребуется
                  children: [
                    IconButton(
                      onPressed: onDatePressed,
                      icon: Icon(Icons.calendar_month),
                    ),
                    IconButton(onPressed: onAddPressed, icon: Icon(Icons.send)),
                    SizedBox(width: 5),
                  ],
                ),
                hintText: 'Добавить новую задачу...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
