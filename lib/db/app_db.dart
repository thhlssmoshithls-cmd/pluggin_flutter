// lib/db/app_db.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDB {
  AppDB._();
  static final AppDB instance = AppDB._();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT,
        username TEXT UNIQUE,
        email TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price INTEGER,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE txns(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        created_at TEXT,
        total INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE txn_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        txn_id INTEGER,
        item_id INTEGER,
        qty INTEGER,
        price INTEGER
      )
    ''');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
