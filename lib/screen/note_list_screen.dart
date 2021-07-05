import 'package:flutter/material.dart';
import 'package:notekeeper_app/model/note.dart';
import 'package:notekeeper_app/screen/note_detail_screen.dart';
import 'package:notekeeper_app/utils/databse_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteListScreen extends StatefulWidget {
  // const NoteListScreen({Key key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
   int count = 0;

  @override
  Widget build(BuildContext context) {
    if(noteList == null ) {
      noteList = <Note>[];

      updateListView();

    }

    return Scaffold(
      ///App bar
      appBar: AppBar(
        title: Text("Notes"),
      ),
      /// End Appbar


      ///Body
       body: ListView.builder(
         itemCount: count,
         itemBuilder: (context, index) {
           return Card(
             color: Colors.white,
             elevation: 2.0,
             child: ListTile(
                 leading: CircleAvatar
                   (backgroundColor: getPriorityColor(this.noteList[index].priority),
                     child: getPriorityIcon(this.noteList[index].priority)),
                 title: Text(this.noteList[index].title,
                 ),
                 subtitle: Text(this.noteList[index].date),
                 trailing: GestureDetector(
                   onTap: () {
                     _delete(context, noteList[index]);
                   },
                   child: Icon(Icons.delete,
                     color: Colors.blueGrey,),
                 ),
                 onTap: () {
                   debugPrint("Tester Deleter");
                   navigateToDetail(this.noteList[index], "Edit Note");
                 }
             ),
           );

         },
       ),
      ///end body

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note("", "", 2), "Add Note");
        },
          tooltip: "Add note",
          child: Icon(Icons.add),
      ),

    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context){
          return NoteDetailScreen(appBarTittle: title, note: note,
          );
        }));

    if (result == true ) {
      updateListView();
    }

  }
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
      return Colors.red;
      break;
      case 2:
      return Colors.yellow;
      break;
      default:
        return Colors.yellow;

    }

  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
}

void _delete(BuildContext context, Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted Succsessfully");

      updateListView();

    }
}

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }




}
