import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/database_bloc.dart';
import 'bloc/database_state.dart';
import 'bloc/todo_bloc.dart';
import 'bloc/todo_state.dart';
import 'constants/constants.dart';
import 'detail_page.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<DatabaseBloc>(
            create: (context) => DatabaseBloc()..initializeDatabase(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Constants.primaryColor, centerTitle: true)),
      debugShowCheckedModeBanner: false,
      home: const Homepage(title: 'Todo App with Sqflite + Bloc'),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _text = TextEditingController();
  TodoBloc? _todoBloc;
  final TextEditingController _description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocConsumer<DatabaseBloc, DatabaseState>(
        listener: (context, state) {
          if (state is LoadDatabase) {
            _todoBloc =
                TodoBloc(database: context.read<DatabaseBloc>().database!);
          }
        },
        builder: (context, state) {
          if (state is LoadDatabase) {
            return BlocProvider<TodoBloc>(
                create: (context) => _todoBloc!..getTodos(),
                child: BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    if (state is InitTodoState) {
                      final todos = _todoBloc!.todos;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8),
                                itemCount: todos.length,
                                itemBuilder: (context, i) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: ((context) => DetailsPage(
                                                bloc: _todoBloc!,
                                                todo: todos[i],
                                              )),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(bottom: 14),
                                      child: Card(
                                        elevation: 10,
                                        color: Colors.black87,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                todos[i].title.toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        _todoBloc!.removeTodo(
                                                            todos[i].id);
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  },
                ));
          }

          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.primaryColor,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext cx) {
                return AlertDialog(
                  title: const Text(
                    Constants.addTodo,
                    style: TextStyle(
                        fontSize: 25,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                          alignment: Alignment.topLeft, child: Text('Title')),
                      Flexible(
                        child: TextFormField(
                          maxLines: 1,
                          controller: _text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                          alignment: Alignment.topLeft,
                          child: Text('Description')),
                      Flexible(
                        child: TextFormField(
                          maxLines: 2,
                          controller: _description,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      style: Constants.customButtonStyle,
                      onPressed: () {
                        Navigator.pop(cx);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: Constants.customButtonStyle,
                      onPressed: () async {
                        if (_text.text.isNotEmpty &&
                            _description.text.isNotEmpty) {
                          _todoBloc!.addTodos(_text.text, _description.text);
                          Navigator.pop(context);
                          _text.clear();
                          _description.clear();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Constants.primaryColor,
                            duration: Duration(seconds: 1),
                            content: Text("Added todo successfully"),
                          ));
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              });
        },
        tooltip: Constants.addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
