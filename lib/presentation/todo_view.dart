/*

TO DO VIEW  : responsible for UI

- use BlocBuilder

 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_bloc_isar/domain/models/todo.dart';
import 'package:todo_bloc_isar/presentation/todo_cubit.dart';

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  // show dialog box for user to type
  void _showAddTodoBox(BuildContext context){
    final todoCubit = context.read<TodoCubit>();
    final textController = TextEditingController();

    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(controller: textController),
        actions: [
          // cancel btn
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text("Cancel")),

          TextButton(
            onPressed: () {
              todoCubit.addTodo(textController.text);
              Navigator.of(context).pop();
            }, 
            child: const Text("Add"))

        ],
      )
    );
  }

  void _showEditTodoBox(BuildContext context, Todo todo){
    final todoCubit = context.read<TodoCubit>();
    final textController = TextEditingController(text: todo.text);

    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        
        content: TextField(controller: textController),
        actions: [
          // cancel btn
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text("Cancel")),

          TextButton(
            onPressed: () {
              if(textController.text.isNotEmpty){
                final updatedTodo = Todo(
                  id: todo.id,
                  text: textController.text,
                  isCompleted: todo.isCompleted
                );
                todoCubit.editTodo(updatedTodo);
              }
              
              Navigator.of(context).pop();
            }, 
            child: const Text("Edit"))

        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoCubit = context.read<TodoCubit>();
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 159, 99, 226),
        appBar: AppBar(
          title: const Text('Le Simple Todo'),
          backgroundColor: Color.fromARGB(255, 33, 57, 94),
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
       floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddTodoBox(context),
       ),

       // BLOC BUILDER
       body: BlocBuilder<TodoCubit, List<Todo>>(
        builder: (context, todos){
          return Padding(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index){
                 //get individual todo from todo list
                final todo = todos[index];
            
                return Slidable(
            
                    // EDIT BTN
                    startActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                        SlidableAction(
                          onPressed: (context) => _showEditTodoBox(context, todo),
                          icon: Icons.edit,
                          backgroundColor: Colors.lightGreen,
                          foregroundColor: Colors.white,
                          // borderRadius: BorderRadius.circular(15),
                        ),
                      ],
                    ),
                    
                    //DELETE BTN
                    endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                        SlidableAction(
                          onPressed: (context) => todoCubit.deleteTodo(todo),
                          icon: Icons.delete,
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          // borderRadius: BorderRadius.circular(15),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        // borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        title: Text(
                          todo.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            // fontSize: 16
                          ),
                        ),
                        leading: Checkbox(
                          value: todo.isCompleted, 
                          onChanged: (value) => todoCubit.toggleCompletion(todo),
                          checkColor: Colors.black,
                          activeColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      )
                  ),
                );
              }
            ),
          );
        }
      )
    );
  }


  // @override
  // Widget build(BuildContext context) {

  //   // todo cubit
  //   final todoCubit = context.read<TodoCubit>();
  //   return Scaffold(
  //     floatingActionButton: FloatingActionButton(
  //       child: const Icon(Icons.add),
  //       onPressed: () => _showTodoBox(context),
  //     ),
      
  //     // BLOC BUILDER
  //     body: BlocBuilder<TodoCubit, List<Todo>>(
  //       builder: (context, todos){
  //         // List View
  //         return ListView.builder(
  //           itemCount: todos.length,
  //           itemBuilder: (context, index){
  //             //get individual todo from todo list
  //             final todo = todos[index];

  //             // List Tile UI
  //             return ListTile(
  //               //text
  //               title: Text(todo.text),
  //               //check box
  //               leading: Checkbox(
  //                 value: todo.isCompleted, 
  //                 onChanged: (value) => todoCubit.toggleCompletion(todo),
  //               ),
  //               // delete box
  //               trailing: IconButton(
  //                 onPressed: () => todoCubit.deleteTodo(todo), 
  //                 icon: Icon(Icons.cancel)),
  //             );
  //           }
  //         );
  //       }
  //       )
  //   );
  // }
}