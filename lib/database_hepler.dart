import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<void> initDB() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_users.db');

    _db = await openDatabase(
      path,
      version: 2, // 👈 subimos la versión
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          );
        ''');

        // 👇 si es una instalación nueva, también creamos characters
        await db.execute('''
          CREATE TABLE characters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            class TEXT NOT NULL
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS characters (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              class TEXT NOT NULL
            );
          ''');
        }
      },
    );
  }

  // ====== USERS (igual que antes) ======
  Future<void> insertUser(String username, String password) async {
    final db = _db;
    if (db == null) throw Exception('La base de datos no está inicializada');
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<bool> validateUser(String username, String password) async {
    final db = _db;
    if (db == null) throw Exception('La base de datos no está inicializada');
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  // ====== CHARACTERS ======
  Future<int> insertCharacter(String name, String klass) async {
    final db = _db;
    if (db == null) throw Exception('La base de datos no está inicializada');
    return db.insert('characters', {'name': name, 'class': klass});
  }

  Future<List<Map<String, dynamic>>> getCharacters() async {
    final db = _db;
    if (db == null) throw Exception('La base de datos no está inicializada');
    return db.query('characters', orderBy: 'id DESC');
  }
}
