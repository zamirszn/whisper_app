import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('texts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE texts (
      id $idType,
      content $textType
    )
    ''');
  }

  Future<int> add(String content) async {
    final db = await instance.database;
    final id = await db.insert('texts', {'content': content});
    return id;
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    final result = await db.query('texts');
    return result;
  }

  Future<int> update(int id, String content) async {
    final db = await instance.database;
    return db.update(
      'texts',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(
      'texts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
