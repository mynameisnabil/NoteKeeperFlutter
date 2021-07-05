import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper_app/model/note.dart';
import 'package:notekeeper_app/utils/databse_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final String appBarTittle;
  final Note note;

   NoteDetailScreen({Key key,  this.appBarTittle,  this.note}) : super(key: key);


  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState(this.appBarTittle, this.note );
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {

  List _priority = ["High", "Low"];

  DatabaseHelper helper = DatabaseHelper();
  Note note;
  String appBarTittle;
  var _formKey = GlobalKey<FormState>();

  TextEditingController tittleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailScreenState(this.appBarTittle , this.note );

  @override
  Widget build(BuildContext context) {

    tittleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTittle),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              /// DropDown
              ListTile(
                title: DropdownButton(
                  items: _priority.map((dropDownItem) => DropdownMenuItem(
                    value: dropDownItem,
                    child: Text(dropDownItem),
                  )).toList(),
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelected){
                    setState(() {
                      debugPrint("User Selected $valueSelected");

                      updatePriority(valueSelected.toString());
                    });
                  },
                ),
              ),
              /// Text Field

              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  controller: tittleController,
                  keyboardType: TextInputType.text,
                  validator: (String value) {
                    if(value.isEmpty) {
                      return "Please Insert Tittle";
                    }
                  },
                  onChanged: (value) {
                    debugPrint("Tulis Sesuatu di Text Input");
                    updateTittle();
                  },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.text,
                  validator: (String value) {
                    if(value.isEmpty) {
                      return "Please Insert Description";
                    }
                  },
                  onChanged: (value) {
                    debugPrint("Seseorang Menulis Sesuatu di Text Input Isi");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Isi Note',
                      errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              /// Button save dan delete
              Padding(padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColorDark
                      ),
                      child: Text("Save", textScaleFactor: 1.2,),
                    ),
                  ),

                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColorDark
                      ),
                      child: Text("Delete", textScaleFactor: 1.2,),
                    ),
                  )

                ],
              ),),

            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    note.date = DateFormat.yMMMd().format(DateTime.now());

    moveTolastScreen();

    int result;

    if (note.id != null) {
      result = await helper.updateNote(note);

    }else{
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog("Status", "Note saved Successfully");
    }else{
      _showAlertDialog("Status", "Problem Saving Note");

    }
  }

  void _delete() async {
    moveTolastScreen();

    if (note.id == null ) {
      _showAlertDialog("Status", "No note was deleted");
      return;

    }

    int result = await helper.deleteNote(note.id);
    if (result != 0){
      _showAlertDialog("Status", "No deleteed successfully ");

    }else{
      _showAlertDialog("Status", "Errorr ");

    }

  }

  void moveTolastScreen() {
    Navigator.pop(context, true);
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }



  void updatePriority(String value) {
    switch(value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priority[0];
        break;
      case 2:
        priority = _priority[1];
        break;
    }
    return priority;

  }

  void updateTittle() {
    note.title = tittleController.text;
  }


  void updateDescription() {
    note.description = descriptionController.text;
  }
}
