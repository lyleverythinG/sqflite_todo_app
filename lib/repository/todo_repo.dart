import 'package:sqflite/sqlite_api.dart';
import '../models/todo_model.dart';

class TodoRepository {
  Future<List<Todo>> getTodos({
    required Database database,
  }) async {
    final datas = await database.rawQuery('SELECT * FROM todo');
    List<Todo> todos = [];
    for (var item in datas) {
      todos.add(Todo(item['id'] as int, item['name'] as String,
          item['description'] as String));
    }
    return todos;
  }

  Future<dynamic> addTodo(
      {required Database database,
      required String text,
      required String description}) async {
    return await database.transaction((trans) async {
      await trans.rawInsert(
          "INSERT INTO todo (name, description) VALUES ('$text','$description')");
    });
  }

  Future<dynamic> updateTodo({
    required Database database,
    required String newTitle,
    required String newDescription,
    required int id,
  }) async {
    return await database.transaction((trans) async {
      await trans.rawUpdate(
          "UPDATE todo SET name = '$newTitle', description = '$newDescription'  WHERE id = $id");
    });
  }

  Future<dynamic> removeTodo({
    required Database database,
    required int id,
  }) async {
    return await database.transaction((trans) async {
      await trans.rawDelete('DELETE FROM todo where id = $id');
    });
  }
}
