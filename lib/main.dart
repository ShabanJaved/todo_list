import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const ToDoApp());

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ToDoListScreen(),
    );
  }
}

class ToDo {
  String title;
  bool isCompleted;

  ToDo({
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
      };

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<ToDo> _todoList = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    final tasks = _prefs.getStringList('tasks');
    if (tasks != null) {
      setState(() {
        _todoList =
            tasks.map((task) => ToDo.fromJson(json.decode(task))).toList();
      });
    }
  }

  void _saveTasks() {
    final tasks = _todoList.map((task) => json.encode(task.toJson())).toList();
    _prefs.setStringList('tasks', tasks);
  }

  void _addTask(String title) {
    setState(() {
      _todoList.add(ToDo(
        title: title,
      ));
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _todoList[index].isCompleted = !_todoList[index].isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          TaskInput(onAdd: _addTask),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final todo = _todoList[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => _toggleTaskCompletion(index),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskInput extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController _controller = TextEditingController();

  TaskInput({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'New Task'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                onAdd(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
