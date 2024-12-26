import 'package:flutter/material.dart';
import 'package:todolist/constraints/colors.dart';

import '../modal/todo.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final onToDoChanged;
  final OnDeleteItem;


  const ToDoItem({super.key, required this.todo,required this.OnDeleteItem,required this.onToDoChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        onTap: () {
          onToDoChanged(todo);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone!? Icons.check_box:Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Text(
          todo.toDoText!,
          style: TextStyle(
              color: tdBlack,
              fontWeight: FontWeight.w500,
              decoration: todo.isDone! ? TextDecoration.lineThrough:null,
              fontSize: 19),
        ),
        trailing: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
              color: tdRed, borderRadius: BorderRadius.circular(8)),
          child: IconButton(
              color: Colors.white,
              iconSize: 18,
              onPressed: () {
                OnDeleteItem(todo.id);
              },
              icon: Icon(Icons.delete)),
        ),
      ),
    );
  }
}
