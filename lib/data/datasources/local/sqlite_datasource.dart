import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';

class SQLiteDataSource {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUserPrefs} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableRecentOrders} (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        clientName TEXT NOT NULL,
        serviceType TEXT NOT NULL,
        apartmentSize TEXT NOT NULL,
        status TEXT NOT NULL,
        priceMin REAL NOT NULL,
        priceMax REAL NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCachedPrices} (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cachedAt INTEGER NOT NULL
      )
    ''');
  }

  // ─── USER PREFERENCES ─────────────────────────────────────────────────────

  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      AppConstants.tableUserPrefs,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableUserPrefs,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> deletePreference(String key) async {
    final db = await database;
    await db.delete(
      AppConstants.tableUserPrefs,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearAllPreferences() async {
    final db = await database;
    await db.delete(AppConstants.tableUserPrefs);
  }

  // ─── RECENT ORDERS ────────────────────────────────────────────────────────

  Future<void> cacheRecentOrder(Map<String, dynamic> order) async {
    final db = await database;
    await db.insert(
      AppConstants.tableRecentOrders,
      order,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentOrders(String clientId) async {
    final db = await database;
    return db.query(
      AppConstants.tableRecentOrders,
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'createdAt DESC',
      limit: 10,
    );
  }

  Future<void> clearRecentOrders(String clientId) async {
    final db = await database;
    await db.delete(
      AppConstants.tableRecentOrders,
      where: 'clientId = ?',
      whereArgs: [clientId],
    );
  }

  Future<void> closeDb() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
