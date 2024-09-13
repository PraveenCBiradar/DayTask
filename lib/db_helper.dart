import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
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
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      isLoggedIn INTEGER DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      slno INTEGER NOT NULL,
      kms INTEGER NOT NULL,
      income INTEGER NOT NULL,
      paise INTEGER,
      isConfirmed INTEGER
    )
    ''');
  }

  Future<void> registerUser(String name, String password) async {
    final db = await instance.database;
    await db.insert('users', {
      'name': name,
      'password': password,
      'isLoggedIn': 1,  // Set user as logged in upon registration
    });
  }

  Future<void> loginUser(String name, String password) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );

    if (users.isNotEmpty) {
      await db.update(
        'users',
        {'isLoggedIn': 1},
        where: 'name = ?',
        whereArgs: [name],
      );
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logoutUser() async {
    final db = await instance.database;
    await db.update(
      'users',
      {'isLoggedIn': 0},
      where: 'isLoggedIn = 1',
    );
  }

  Future<bool> isUserLoggedIn() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'isLoggedIn = 1',
    );
    return result.isNotEmpty;
  }

  Future<void> addRecord({
    required String date,
    required int slno,
    required int kms,
    required int income,
    int? paise,
    required bool isConfirmed,
  }) async {
    final db = await instance.database;

    // Check if a record for the current date already exists
    final existingRecords = await db.query(
      'records',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (existingRecords.isEmpty) {
      await db.insert('records', {
        'date': date,
        'slno': slno,
        'kms': kms,
        'income': income,
        'paise': paise,
        'isConfirmed': isConfirmed ? 1 : 0,
      });
    } else {
      throw Exception('Record for the current date already exists.');
    }
  }

  Future<List<Map<String, dynamic>>> searchRecordsByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'records',
      where: 'date = ?',
      whereArgs: [date],
    );
  }
}
