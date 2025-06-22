import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('item_fav.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, fileName);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tbl_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT,
        user_id TEXT,
        item_name TEXT,
        item_desc TEXT,
        item_status TEXT,
        item_qty TEXT,
        item_price TEXT,
        item_delivery TEXT,
        item_date TEXT,
        user_name TEXT,
        user_phone TEXT,
        user_university TEXT
      )
    ''');
  }
}
