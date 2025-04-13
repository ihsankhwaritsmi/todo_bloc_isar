# Flutter TODO app using Bloc and Isar

| Name                         | NRP        | Kelas                                 |
| ---------------------------- | ---------- | ------------------------------------- |
| Muhammad Ihsan Al Khwaritsmi | 5025221211 | Pemograman Perangkat Bergerak (PPB) C |

![alt text](<images/Readme/Frame 1.png>)

This project uses [Bloc](https://pub.dev/packages/flutter_bloc) (flutter_bloc) to create clearer code making it somewhat more readable, scalable, and modular. Although, this project might be seen as too simple to use flutter_bloc on, it serves as a challenge and self-practice as well. The app uses local database [Isar](https://isar.dev/tutorials/quickstart.html) to store todo list data.

## Project Structure
The key of using Bloc is to manage states that exist in our application. Bloc leverages the concept of modularity to make the code easier to read and understand by dividing the code into many sub-files that correspond to each other. The project structure is splitted into three layers as follow:

![alt text](<images/Readme/Frame 2.png>)

- Data  : handles storing, retrieving, updating, deleting in the database.
- Domain    : technlogy agnostics, outlines what operations the app can do.
- Presentation  : Responsible for handling the User Interface.

# Steps
the steps generally started by developing the business logic of the app in the 'Domain' layer and then proceed to make the 'Data' layer before devoloping the 'Presentation' layer. 

## Step 1: update pubspec.yaml
```
flutter pub add isar isar_flutter_libs path_provider
flutter pub add -d isar_generator build_runner
flutter pub add flutter_bloc
```
## Step 2: Manage Project File Structure
```
lib
│   
│
├───data
│   ├───models
│   │       isar_todo.dart
│   │       isar_todo.g.dart
│   │
│   └───repository
│           isar_todo_repo.dart
│
├───domain
│   ├───models
│   │       todo.dart
│   │
│   └───repository
│           todo_repo.dart
│
├───presentation
│        todo_cubit.dart
│        todo_page.dart
│        todo_view.dart
│
└───main.dart
```
## Step 3: Domain Layer

Configure the business logic as follows:

```dart
// lib/domain/models/todo.dart
class Todo {
  final int id;
  final String text;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  Todo toggleCompletion(){
    return Todo(
      id: id,
      text: text,
      isCompleted: !isCompleted,
    );
  }
  
  Todo editText(){
    return Todo(
      id: id,
      text: text,
      isCompleted: isCompleted,
    );
  }
}
```
```dart
// lib/domain/repository/todo_repo.dart
import 'package:todo_bloc_isar/domain/models/todo.dart';

abstract class TodoRepo {
  
  // get list of todos
  Future<List<Todo>> getTodos();

  // add a new todo
  Future<void> addTodo(Todo newTodo);

  // update an existing todo
  Future<void> updateTodo(Todo todo);

  // delete a todo
  Future<void> deleteTodo(Todo todo);
}
```
The purpose of Domain layer was to define the overall logic of the application so do not worry about technology or framework just yet. The class `TodoRepo` uses abstract class to define the supposed functionality of a TODO app.

## Step 4: Data Layer
Define the schema for our database:
```dart
// lib/data/models/isar_todo.dart

import 'package:isar/isar.dart';
import 'package:todo_bloc_isar/domain/models/todo.dart';

part 'isar_todo.g.dart';

@collection
class TodoIsar{
  Id id = Isar.autoIncrement;
  late String text;
  late bool isCompleted;

  // convert isar object -> pure todo object to use in our app
  Todo toDomain(){
    return Todo(
      id: id,
      text: text,
      isCompleted: isCompleted,
    );
  }

  // convert pure todo object -> isar object to store in isar db
  static TodoIsar fromDomain(Todo todo){
    return TodoIsar()
    ..id = todo.id
    ..text = todo.text
    ..isCompleted = todo.isCompleted;
  }
}
```
Execute the following command to start the `build_runner`:
```
dart run build_runner build
```
This will result in the creation of `todo.g.dart` indicating that the schema is ready to use. Then, proceed to create the functionality of the Data layer as follow:

```dart
// lib/data/repository/isar_todo_repo.dart

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
```
The code structure is generally the same as the Domain layer. This is due to the abstract class which was previously created in the `todo_repo.dart`.

## Step 5: Presentation Layer
Here we focus on developing the User Interface of the app. 
```dart
// lib/presentation/todo_cubit.dart

class TodoCubit extends Cubit<List<Todo>> {
  // reference todo repo
  final TodoRepo todoRepo;

  // Constructor initializes the cubit with an empty list
  TodoCubit(this.todoRepo) : super([]){
    loadTodos();
  }

  // LOAD
  Future<void> loadTodos() async {
    // fetch list of todos from repo
    final todoList = await todoRepo.getTodos();
    
    // emit the fetched list as the new state
    emit(todoList);
  }

  // ADD
  Future<void> addTodo(String text) async {
    // create a new todo with unique Id
    final newTodo = Todo(
      id : DateTime.now().millisecondsSinceEpoch,
      text: text
    );

    // save the new todo to repo
    await todoRepo.addTodo(newTodo);

    //re-load
    loadTodos();
  }

  // DELETE
  Future<void> deleteTodo(Todo todo) async {
   // delete the provided todo from repo
   await todoRepo.deleteTodo(todo);

   //re-load
   loadTodos();
  }

  // TOGGLE
  Future<void> toggleCompletion(Todo todo) async {
    // toggle the completion status of provided todo
    final updatedTodo = todo.toggleCompletion();

    // update the todo in repo with new completion status
    await todoRepo.updateTodo(updatedTodo);

    //re-load
    loadTodos();
  }

  // Edit
  Future<void> editTodo(Todo todo) async {
    final editedTodo = todo.editText();

    await todoRepo.updateTodo(editedTodo);
    
    loadTodos();
  }
}
```
The code above was to define the logic of the app at the Presentation layer. The structure might be slightly different for User Interface had many additional functionalities that needs to be addressed.

```dart
// lib/presentation/todo_page.dart

class TodoPage extends StatelessWidget {

  final TodoRepo todoRepo;

  const TodoPage({super.key, required this.todoRepo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>TodoCubit(todoRepo),
      child: const TodoView(),
      );
  }
}
```
The final steps then is to make the interface ships with the supposed features of any todo app. I reccomend open the `todo_view.dart` for further analysis.