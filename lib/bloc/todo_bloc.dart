import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo_sqflite/bloc/todo_state.dart';

import '../models/todo_model.dart';
import '../repository/todo_repo.dart';

class TodoBloc extends Cubit<TodoState> {
  final _todoRepo = TodoRepository();
  final Database database;
  TodoBloc({required this.database}) : super(const InitTodoState(0));

  int _counter = 1;
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> getTodos() async {
    try {
      _todos = await _todoRepo.getTodos(database: database);
      emit(InitTodoState(_counter++));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateTodo(
      {required int id,
      required String newTitle,
      required String newDescription}) async {
    try {
      _todos = await _todoRepo.updateTodo(
          database: database,
          id: id,
          newTitle: newTitle,
          newDescription: newDescription);
      emit(InitTodoState(_counter++));
    } catch (e) {
      return;
    }
  }

  Future<void> addTodos(String text, String description) async {
    try {
      await _todoRepo.addTodo(
          database: database, text: text, description: description);
      emit(InitTodoState(_counter++));
      getTodos();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> removeTodo(int id) async {
    try {
      await _todoRepo.removeTodo(database: database, id: id);
      emit(InitTodoState(_counter++));
      getTodos();
    } catch (e) {
      log(e.toString());
    }
  }
}
