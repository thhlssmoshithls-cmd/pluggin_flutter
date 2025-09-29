// lib/repository.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'db/app_db.dart';
import 'models/user.dart';
import 'models/item.dart';
import 'models/txn.dart';

class Repo {
  Repo._();
  static final Repo instance = Repo._();

  Future<String> hashPassword(String plain) async {
    final bytes = utf8.encode(plain);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // USER
  Future<int> createUser(User u) async {
    final db = await AppDB.instance.database;
    return await db.insert('users', u.toMap());
  }

  Future<User?> login(String username, String plainPassword) async {
    final db = await AppDB.instance.database;
    final hashed = await hashPassword(plainPassword);
    final res = await db.query('users',
        where: 'username = ? AND password = ?', whereArgs: [username, hashed]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

  Future<User?> findUserByUsername(String username) async {
    final db = await AppDB.instance.database;
    final res = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

  // ITEMS
  Future<void> seedItemsIfEmpty(List<Item> items) async {
    final db = await AppDB.instance.database;
    final countRes = await db.rawQuery('SELECT COUNT(*) as c FROM items');
    int c = Sqflite.firstIntValue(countRes) ?? 0;
    if (c == 0) {
      final batch = db.batch();
      for (var it in items) {
        batch.insert('items', it.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<Item>> getAllItems() async {
    final db = await AppDB.instance.database;
    final res = await db.query('items');
    return res.map((m) => Item.fromMap(m)).toList();
  }

  Future<List<Item>> searchItems(String q) async {
    final db = await AppDB.instance.database;
    final res = await db.query('items',
        where: 'name LIKE ?', whereArgs: ['%$q%']);
    return res.map((m) => Item.fromMap(m)).toList();
  }

  // TRANSACTIONS
  Future<int> createTxn(Txn txn, List<Map<String, dynamic>> items) async {
    final db = await AppDB.instance.database;
    return await db.transaction<int>((txnDb) async {
      final txnId = await txnDb.insert('txns', txn.toMap());
      for (var it in items) {
        await txnDb.insert('txn_items', {
          'txn_id': txnId,
          'item_id': it['item_id'],
          'qty': it['qty'],
          'price': it['price'],
        });
      }
      return txnId;
    });
  }

  Future<List<Map<String, dynamic>>> getTxnItems(int txnId) async {
    final db = await AppDB.instance.database;
    final res = await db.rawQuery('''
      SELECT ti.qty, ti.price, i.name
      FROM txn_items ti
      JOIN items i ON i.id = ti.item_id
      WHERE ti.txn_id = ?
    ''', [txnId]);
    return res;
  }

  Future<List<Map<String, dynamic>>> reportTotalPerDay() async {
    final db = await AppDB.instance.database;
    final res = await db.rawQuery('''
      SELECT DATE(created_at) as day, SUM(total) as total, COUNT(*) as tx_count
      FROM txns
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at) DESC
    ''');
    return res;
  }
}
