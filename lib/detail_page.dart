import 'package:flutter/material.dart';
import 'bloc/todo_bloc.dart';
import 'constants/constants.dart';
import 'models/todo_model.dart';
import 'widgets/custom_text.dart';

class DetailsPage extends StatefulWidget {
  final Todo todo;
  final TodoBloc bloc;
  const DetailsPage({Key? key, required this.todo, required this.bloc})
      : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TodoBloc? _todoBloc;
  final TextEditingController _newTitle = TextEditingController();
  final TextEditingController _newDescription = TextEditingController();
  @override
  void initState() {
    _todoBloc = widget.bloc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: CustomText(text: 'Title'.toUpperCase()),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.todo.title,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: CustomText(text: 'Description'.toUpperCase()),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.todo.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: Constants.customButtonStyle,
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
                                        alignment: Alignment.topLeft,
                                        child: Text('Title')),
                                    Flexible(
                                      child: TextFormField(
                                        maxLines: 1,
                                        controller: _newTitle,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Align(
                                        alignment: Alignment.topLeft,
                                        child: Text('Description')),
                                    Flexible(
                                      child: TextFormField(
                                        maxLines: 2,
                                        controller: _newDescription,
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
                                      if (_newTitle.text.isNotEmpty &&
                                          _newDescription.text.isNotEmpty) {
                                        _todoBloc!
                                            .updateTodo(
                                          id: widget.todo.id,
                                          newTitle: _newTitle.text,
                                          newDescription: _newDescription.text,
                                        )
                                            .then((value) {
                                          _todoBloc!.getTodos();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            backgroundColor:
                                                Constants.primaryColor,
                                            duration: Duration(seconds: 1),
                                            content:
                                                Text("Todo details updated"),
                                          ));
                                        });
                                      }
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              );
                            });
                      },
                      child: CustomText(text: 'Update'.toUpperCase()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
