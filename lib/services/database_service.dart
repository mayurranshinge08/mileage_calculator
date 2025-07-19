import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/mileage_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mileage_calculator.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mileage_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleType TEXT NOT NULL,
        distance REAL NOT NULL,
        fuelUsed REAL NOT NULL,
        mileage REAL NOT NULL,
        date INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(MileageRecord record) async {
    final db = await database;
    return await db.insert('mileage_records', record.toMap());
  }

  Future<List<MileageRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mileage_records',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return MileageRecord.fromMap(maps[i]);
    });
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('mileage_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllRecords() async {
    final db = await database;
    await db.delete('mileage_records');
  }
}
