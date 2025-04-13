/*

DATABASE REPO

This implements the todo repo and handles storing, retrieving, updating,
deleting in the isar database

 */

import 'package:isar/isar.dart';
import 'package:todo_bloc_isar/data/models/isar_todo.dart';
import 'package:todo_bloc_isar/domain/models/todo.dart';
import 'package:todo_bloc_isar/domain/repository/todo_repo.dart';

class IsarTodoRepo implements TodoRepo {
  // database
  final Isar db;

  IsarTodoRepo(this.db);

  @override
  Future<List<Todo>> getTodos() async {
  // fetch from db
   final todos = await db.todoIsars.where().findAll();
   //return as list of todos and give it to domain layer
   return todos.map((todoIsar)=>todoIsar.toDomain()).toList();
  }


  @override
  Future<void> addTodo(Todo newTodo) async{
   // convert todo into isar todo
   final todoIsar = TodoIsar.fromDomain(newTodo);
   // so that we can store it in our database
   return db.writeTxn(()=>db.todoIsars.put(todoIsar));
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    await db.writeTxn(() => db.todoIsars.delete(todo.id));
  }

  @override
  Future<void> updateTodo(Todo todo) async{
    // convert todo into isar todo
   final todoIsar = TodoIsar.fromDomain(todo);
   // so that we can store it in our database
   return db.writeTxn(()=>db.todoIsars.put(todoIsar));
  }
}