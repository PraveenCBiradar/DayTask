import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // Get the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database schema
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
      kms REAL NOT NULL,
      income REAL NOT NULL,
      paise REAL,
      isConfirmed INTEGER
    )
    ''');

    await db.execute(''' 
    CREATE TABLE overtime (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      timeWorked TEXT NOT NULL,
      slno TEXT NOT NULL,
      kms TEXT NOT NULL,
      isOff INTEGER,
      isNoOT INTEGER
    )
    ''');
  }

  // Register user
  Future<void> registerUser(String name, String password) async {
    final db = await instance.database;
    await db.insert('users', {
      'name': name,
      'password': password,
      'isLoggedIn': 0, // Set default value for 'isLoggedIn' to 0 (not logged in)
    });
  }

  // Login user
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

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final db = await instance.database;

    // Get the user that is logged in (isLoggedIn = 1)
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'isLoggedIn = ?',
      whereArgs: [1],
    );

    // Return true if a user is logged in, otherwise false
    return result.isNotEmpty;
  }

  // Add record
  Future<void> addRecord({
    required String date,
    required int slno,
    required double kms,
    required double income,
    double? paise,
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
        'paise': paise ?? 0.0, // Defaults to 0.0 if paise is null
        'isConfirmed': isConfirmed ? 1 : 0,
      });
    } else {
      throw Exception('Record for the current date already exists.');
    }
  }

  // Search records by date
  Future<List<Map<String, dynamic>>> searchRecordsByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'records',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // Search records by date range
  Future<List<Map<String, dynamic>>> searchRecordsByDateRange(
      String startDate, String endDate, String sortOrder) async {
    final db = await instance.database;

    final orderBy = sortOrder == 'Ascending' ? 'date ASC' : 'date DESC';

    return await db.query(
      'records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: orderBy,
    );
  }

  // Save overtime record
  Future<void> saveOvertimeRecord({
    required String date,
    required String timeWorked,
    required String slno,
    required String kms,
    required bool isOff,
    required bool isNoOT,
  }) async {
    final db = await instance.database;

    final data = {
      'date': date,
      'timeWorked': timeWorked,
      'slno': slno,
      'kms': kms,
      'isOff': isOff ? 1 : 0,
      'isNoOT': isNoOT ? 1 : 0,
    };

    await db.insert('overtime', data);
  }

  // Delete record by id
  Future<void> deleteRecord(int id) async {
    final db = await instance.database;
    await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Other existing methods remain unchanged...
}
