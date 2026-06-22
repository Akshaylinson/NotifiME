import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableApps} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_name TEXT,
        package_name TEXT UNIQUE,
        icon_path TEXT,
        notification_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableNotifications} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_id INTEGER,
        sender TEXT,
        title TEXT,
        message TEXT,
        timestamp INTEGER,
        read_status INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 1,
        FOREIGN KEY (app_id) REFERENCES ${AppConstants.tableApps} (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSettings} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voice TEXT,
        speech_rate REAL,
        pitch REAL,
        auto_read INTEGER DEFAULT 0,
        retention_days INTEGER DEFAULT 7
      )
    ''');
  }
}
