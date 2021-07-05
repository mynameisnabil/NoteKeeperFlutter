import 'dart:io';

import 'package:notekeeper_app/model/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  DatabaseHelper._createInstance();

  ///membuat table database
  String noteTable = "note_table";

  ///isi data table
  String colId= 'id';
  String colTitle= 'title';
  String colDesription= 'description';
  String colPriority= 'priority';
  String colDate= 'date';


  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();

    }
    return _databaseHelper;
  }

  // Bagian get database :
  // Membuat inisialisasi database
  Future<Database> initializeDatabase() async {
    //Get the directory path for both Android and IOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    // Membuat nama databasenya
    String path = directory.path + 'notes.db';

    // Open/create the database at a given path
    var notesDatabase =
    // untuk kasus kita menggunakan version 1
    // version 1 untuk menentukan skema(rancangan) dari database yang dibuka
    await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }




  ///membuat table database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
            '$colDesription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Membuat getter untuk database kita :
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }


  //Fetch operation: Get all note objects from database :
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    var result = await db.query(noteTable,
        orderBy: '$colPriority ASC'); // ini helper function
    return result;
  }

  ///insert data
  Future<int>insertNote(Note note) async {
    Database db = await this.database;

    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  /// Update Data
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  /// Delete Data
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }
  ///get jumlah data
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = <Note>[];
    // for loop to create a 'Note List' from a 'Map List' :
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }







}