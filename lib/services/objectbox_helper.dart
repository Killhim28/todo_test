import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../objectbox.g.dart';
import 'todo_db.dart';

class ObjectboxHelper {
  late final Store store;
  late final Box<TodoDb> todoBox;

  ObjectboxHelper._create(this.store) {
    todoBox = Box<TodoDb>(store);
  }
  static Future<ObjectboxHelper> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "todo_database");

    final store = await openStore(directory: storeDir);
    return ObjectboxHelper._create(store);
  }
}
