import 'package:objectbox/objectbox.dart';
import '../models/todo_class.dart';

@Entity()
class TodoDb {
  @Id()
  int id;
  String title;
  @Property(type: PropertyType.date)
  DateTime date;
  bool completed;
  int priorityIndex;
  String? imagePath;

  bool isDeleted;
  // enum напрямую в бд не передать
  @Transient()
  TodoPriority get priority {
    if (priorityIndex >= 0 && priorityIndex < TodoPriority.values.length) {
      return TodoPriority.values[priorityIndex];
    }
    return TodoPriority.low;
  }

  @Transient()
  set priority(TodoPriority value) {
    priorityIndex = value.index;
  }

  TodoDb({
    this.id = 0,
    required this.title,
    required this.date,
    required this.completed,
    required this.priorityIndex,
    this.isDeleted = false,
    required this.imagePath,
  });
}
