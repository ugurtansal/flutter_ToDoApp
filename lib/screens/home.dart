import 'package:flutter/material.dart';
import 'package:todolist/constraints/colors.dart';
import 'package:todolist/modal/db_helper.dart';
import 'package:todolist/modal/todo.dart';
import 'package:todolist/widget/to_do_widget.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList;
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _loadToDos(); // Asenkron işlem burada başlatılır.

    super.initState();
  }
  Future<void> _loadToDos() async {
    final todos = await ToDo.todoList; // Future'dan sonucu bekler.
    setState(() {
      _foundToDo = todos; // Sonucu atar.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.menu,
              color: tdBlack,
              size: 30,
            ),
            Icon(Icons.account_circle)
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(
                  onChanged: _runFilter,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 80),
                    // Alt boşluk ekleniyor
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 15),
                        child: Text(
                          "All ToDos",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      for (ToDo todo in _foundToDo)
                        ToDoItem(
                          todo: todo,
                          onToDoChanged: _handleToDoChanges,
                          OnDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            // Liste içerisinde bir veya daha fazla BoxShadow olabilir
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                          hintText: "Add a new to do item",
                          border: InputBorder.none),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: tdBlue,
                        minimumSize: Size(75, 50),
                        elevation: 10),
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    child: Text(
                      "+",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleToDoChanges(ToDo todo) async {
    // Veritabanına erişim sağlanıyor
    final db = await DatabaseHelper().database;

    // 'isDone' durumunu değiştiriyoruz
    todo.isDone = !todo.isDone!;

    // Veritabanındaki öğeyi güncelliyoruz
    await db.update(
      'todos', // Tablonun adı
      {
        'id': todo.id,
        'toDoText': todo.toDoText,
        'isDone': todo.isDone! ? 1 : 0, // Boolean değeri 0 veya 1 olarak kaydediyoruz
      },
      where: 'id = ?', // Koşul
      whereArgs: [todo.id], // id değeri ile eşleşen öğe
    );

    // Veritabanı güncellemesi tamamlandıktan sonra UI'yi güncellemek için setState
    setState(() {});
  }


  void _deleteToDoItem(String id) async {
    // Veritabanına erişim sağlanıyor
    final db = await DatabaseHelper().database;

    // Veritabanından öğe siliniyor
    await db.delete(
      'todos', // Tablonun adı
      where: 'id = ?', // Koşul belirtiyoruz
      whereArgs: [id], // '?' yerine geçecek değer
    );

    // Silme işlemi tamamlandığında, UI'yi güncellemek için setState kullanıyoruz
    setState(() {
      // Silinen öğeyi listeden çıkarıyoruz
      _foundToDo.removeWhere((item) => item.id == id);
    });
  }


  void _addToDoItem(String todo) async {
    final newTodo = ToDo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      toDoText: todo,
    );

    await DatabaseHelper().insertToDo(newTodo);

    setState(() {
      _foundToDo.add(newTodo);
    });

    _todoController.clear();
  }


  void _runFilter(String enteredKey) async {
    // Veritabanından todo listesine erişim sağlıyoruz
    final db = await DatabaseHelper().database;

    // Eğer arama kutusu boşsa, tüm todos listesi gösterilsin
    List<Map<String, dynamic>> queryResult;
    if (enteredKey.isEmpty) {
      queryResult = await db.query('todos'); // Tüm veriler çekiliyor
    } else {
      queryResult = await db.query(
        'todos',
        where: 'toDoText LIKE ?', // Arama yapılacak alan
        whereArgs: ['%$enteredKey%'], // Kullanıcının girdiği değeri arıyoruz
      );
    }

    // Veritabanından gelen ham veriyiToDo listesine dönüştürme
    List<ToDo> filteredToDos = queryResult.map((todoMap) {
      return ToDo(
        id: todoMap['id'],
        toDoText: todoMap['toDoText'],
        isDone: todoMap['isDone'] == 1, // 1 ise true, 0 ise false
      );
    }).toList();

    // UI'yi güncelleme
    setState(() {
      _foundToDo = filteredToDos;
    });
  }

}

extension on Future<List<ToDo>> {
  where(Function(dynamic item) param0) {}
}



class searchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const searchBox({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: tdBlack,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(
              maxHeight: 20,
              minWidth: 25,
            ),
            border: InputBorder.none,
            hintText: "Search",
            hintStyle: TextStyle(color: tdGrey)),
      ),
    );
  }
}
