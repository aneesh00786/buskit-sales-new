// import 'dart:convert';
// import 'dart:developer';

// import 'package:busskit_salesexecutive/database/sqflite_database/database_keys.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   static Database? _database;

//   // Open the database
//   static Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   // Initialize the database
//   static Future<Database> _initDatabase() async {
//     final String databasesPath = await getDatabasesPath();
//     final String path = join(databasesPath, SqlDatabaseKey.databaseName);
//     final database = await openDatabase(
//       path,
//       version: SqlDatabaseKey.databaseVersion,
//       onCreate: _createTables,
//     );
//     log("database Qerryr ${database.path}");
//     return database;
//   }

//   // Create tables
//   static Future<void> _createTables(Database db, int version) async {
//     await db.execute(
//         'CREATE TABLE IF NOT EXISTS ${SqlDatabaseKey.buyProduct} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
//   }

//   static Future<void> insertItem(Map<String, Object?> item,
//       {required String collumName}) async {
//     if (await checkItemExists(item['name'].toString(),
//         collumName: collumName)) {
//       await updateItem(item, collumName: collumName);
//     } else {
//       final Database db = await database;

//       int id = await db.insert(collumName, {"name": jsonEncode(item['name'])});
//       log("DATABSE Tabel Inserted ID: $id");
//     }
//   }

//   // Update an item in the database
//   static Future<void> updateItem(Map<String, Object?> item,
//       {required String collumName}) async {
//     final Database db = await database;
//     int id = await db.update(
//       collumName,
//       item,
//       where: 'id = ?',
//       whereArgs: [item['id']],
//     );
//     log("DATABSE Tabel Updated ID: $id");
//   }

//   // Check if an item exists in the table
//   static Future<bool> checkItemExists(String itemId,
//       {required String collumName}) async {
//     final Database db = await database;
//     List<Map<String, dynamic>> result = await db.query(
//       collumName,
//       where: 'name = ?',
//       whereArgs: [jsonEncode(itemId)],
//       limit: 1,
//     );
//     return result.isNotEmpty;
//   }

//   // Delete an item from the database
//   static Future<bool> deleteItem(int id, {required String collumName}) async {
//     final Database db = await database;
//     int dbId = await db.delete(
//       collumName,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (dbId != 0) {
//       return false;
//     } else {
//       log("DATABSE Tabel Deleted ID: $dbId");
//       return true;
//     }
//   }

//   // Delete all data from a table
//   static Future<void> deleteAllTabelData({required String collumName}) async {
//     final Database db = await database;
//     await db.delete(collumName);
//     log('DATABASE CLEARED', error: "ALL DATA DELETED");
//   }

//   // Retrieve all data from the database
//   static Future<List<Map<String, dynamic>>> getAllData(
//       {required String collumName}) async {
//     final Database db = await database;
//     log("All Data Is Thair ${await db.query(collumName)}");
//     return await db.query(collumName);
//   }
// }
