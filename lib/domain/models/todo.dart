/*
TO DO MODEL

todo object be like:
___________________________________________

has 3 properties:
- id
- text
- isCompeted
___________________________________________

Methods:
- toggle completion ON and OFF

 */

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
