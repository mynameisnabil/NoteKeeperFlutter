import 'package:flutter/material.dart';
import 'package:notekeeper_app/screen/note_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: NoteListScreen(),
    );
  }
}
