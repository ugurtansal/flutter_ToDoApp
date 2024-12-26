import 'package:todolist/modal/db_helper.dart';

class ToDo {
  String? id;
  String? toDoText;
  bool? isDone ;

  ToDo({
    required this.id,
    required this.toDoText,
    this.isDone=false
  });
/*
  static Future<List<ToDo>> todoList() {
    return DatabaseHelper().getToDoList();
    /*
     [
      ToDo(id: '01', toDoText: 'Morning Excercise', isDone: true ),
      ToDo(id: '02', toDoText: 'Buy Groceries', isDone: true ),
      ToDo(id: '03', toDoText: 'Check Emails', ),
      ToDo(id: '04', toDoText: 'Team Meeting', ),
      ToDo(id: '05', toDoText: 'Work on mobile apps for 2 hour', ),
      ToDo(id: '06', toDoText: 'Dinner with Jenny', ),
    ];

     */
  }

 */
  static Future<List<ToDo>> todoList=  DatabaseHelper().getToDoList() ;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toDoText': toDoText,
      'isDone': isDone == true ? 1 : 0,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      toDoText: map['toDoText'],
      isDone: map['isDone'] == 1,
    );
  }
}