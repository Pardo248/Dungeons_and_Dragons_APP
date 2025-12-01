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
      version: 7, // 👈 NUEVA VERSIÓN
      onCreate: (db, _) async {
        // ===== USERS =====
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          );
        ''');

        // ===== CHARACTERS =====
        await db.execute('''
          CREATE TABLE characters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            class TEXT NOT NULL,
            level INTEGER NOT NULL DEFAULT 1
          );
        ''');

        // ===== MOCHILA =====
        await db.execute('''
          CREATE TABLE mochila (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL UNIQUE,
            pc  INTEGER NOT NULL DEFAULT 0,
            pp  INTEGER NOT NULL DEFAULT 0,
            pe  INTEGER NOT NULL DEFAULT 0,
            po  INTEGER NOT NULL DEFAULT 0,
            ppt INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');

        await db.execute('''
          CREATE TABLE mochila_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            quantity INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');

        // ===== HISTORIA =====
        await db.execute('''
          CREATE TABLE character_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL UNIQUE,
            personality_traits TEXT,
            ideals TEXT,
            bonds TEXT,
            flaws TEXT,
            journal TEXT,
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');

        // ===== MAGIC =====
        await db.execute('''
          CREATE TABLE character_magic (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL UNIQUE,
            magic_ability TEXT,
            save_dc INTEGER,
            attack_bonus INTEGER,
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');

        // ===== STATS =====
        await db.execute('''
          CREATE TABLE character_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL UNIQUE,
            str_score INTEGER,
            str_mod INTEGER,
            dex_score INTEGER,
            dex_mod INTEGER,
            con_score INTEGER,
            con_mod INTEGER,
            int_score INTEGER,
            int_mod INTEGER,
            wis_score INTEGER,
            wis_mod INTEGER,
            cha_score INTEGER,
            cha_mod INTEGER,
            inspiration INTEGER,
            proficiency_bonus INTEGER,
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');

        // ===== SPELL SLOTS =====
        await db.execute('''
          CREATE TABLE spell_slots (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            level INTEGER NOT NULL,
            max_slots INTEGER NOT NULL DEFAULT 0,
            used_slots INTEGER NOT NULL DEFAULT 0,
            UNIQUE(character_id, level),
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');

        // ===== CHARACTER SPELLS =====
        await db.execute('''
          CREATE TABLE character_spells (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            level INTEGER NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            known INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (character_id) REFERENCES characters(id)
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v1->v2: asegurar characters
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS characters (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              class TEXT NOT NULL
            );
          ''');
        }

        // v2->v3: agregar level + mochila + history
        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE characters ADD COLUMN level INTEGER NOT NULL DEFAULT 1;',
            );
          } catch (_) {}

          await db.execute('''
            CREATE TABLE IF NOT EXISTS mochila (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL UNIQUE,
              pc  INTEGER NOT NULL DEFAULT 0,
              pp  INTEGER NOT NULL DEFAULT 0,
              pe  INTEGER NOT NULL DEFAULT 0,
              po  INTEGER NOT NULL DEFAULT 0,
              ppt INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS mochila_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              description TEXT,
              quantity INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS character_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL UNIQUE,
              personality_traits TEXT,
              ideals TEXT,
              bonds TEXT,
              flaws TEXT,
              journal TEXT,
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');
        }

        // v3->v5: crear magia / slots / spells si faltan
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS character_magic (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL UNIQUE,
              magic_ability TEXT,
              save_dc INTEGER,
              attack_bonus INTEGER,
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS spell_slots (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL,
              level INTEGER NOT NULL,
              max_slots INTEGER NOT NULL DEFAULT 0,
              used_slots INTEGER NOT NULL DEFAULT 0,
              UNIQUE(character_id, level),
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS character_spells (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL,
              level INTEGER NOT NULL,
              name TEXT NOT NULL,
              description TEXT,
              known INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');
        }

        // v5->v7: asegurar character_stats
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS character_stats (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              character_id INTEGER NOT NULL UNIQUE,
              str_score INTEGER,
              str_mod INTEGER,
              dex_score INTEGER,
              dex_mod INTEGER,
              con_score INTEGER,
              con_mod INTEGER,
              int_score INTEGER,
              int_mod INTEGER,
              wis_score INTEGER,
              wis_mod INTEGER,
              cha_score INTEGER,
              cha_mod INTEGER,
              inspiration INTEGER,
              proficiency_bonus INTEGER,
              FOREIGN KEY (character_id) REFERENCES characters(id)
            );
          ''');
        }
      },
    );
  }

  Database _ensureDb() {
    final db = _db;
    if (db == null) {
      throw Exception(
        'La base de datos no está inicializada. Llama a initDB() primero.',
      );
    }
    return db;
  }

  // ===== USERS =====
  Future<void> insertUser(String username, String password) async {
    final db = _ensureDb();
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<bool> validateUser(String username, String password) async {
    final db = _ensureDb();
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  // ===== CHARACTERS =====
  Future<int> insertCharacter(String name, String klass) async {
    final db = _ensureDb();
    return db.insert('characters', {'name': name, 'class': klass});
  }

  Future<List<Map<String, dynamic>>> getCharacters() async {
    final db = _ensureDb();
    return db.query('characters', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getCharacterById(int id) async {
    final db = _ensureDb();
    final res = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<void> updateCharacterLevel(int id, int level) async {
    final db = _ensureDb();
    await db.update(
      'characters',
      {'level': level},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== MOCHILA =====
  Future<Map<String, dynamic>?> getMochilaByPersonId(int personId) async {
    final db = _ensureDb();
    final res = await db.query(
      'mochila',
      where: 'character_id = ?',
      whereArgs: [personId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<void> upsertMochila(int personId, Map<String, dynamic> data) async {
    final db = _ensureDb();
    final row = {
      'character_id': personId,
      'pc': data['pc'] ?? 0,
      'pp': data['pp'] ?? 0,
      'pe': data['pe'] ?? 0,
      'po': data['po'] ?? 0,
      'ppt': data['ppt'] ?? 0,
    };
    await db.insert(
      'mochila',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMochilaItemsByPersonId(
    int personId,
  ) async {
    final db = _ensureDb();
    return db.query(
      'mochila_items',
      where: 'character_id = ?',
      whereArgs: [personId],
      orderBy: 'id ASC',
    );
  }

  Future<int> insertMochilaItem(
    int personId,
    String name,
    String description,
    int quantity,
  ) async {
    final db = _ensureDb();
    return db.insert('mochila_items', {
      'character_id': personId,
      'name': name,
      'description': description,
      'quantity': quantity,
    });
  }

  Future<void> updateMochilaItemQuantity(int itemId, int quantity) async {
    final db = _ensureDb();
    await db.update(
      'mochila_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> deleteMochilaItem(int itemId) async {
    final db = _ensureDb();
    await db.delete(
      'mochila_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  // ===== HISTORIA =====
  Future<Map<String, dynamic>?> getHistoriaByPersonId(int personId) async {
    final db = _ensureDb();
    final res = await db.query(
      'character_history',
      where: 'character_id = ?',
      whereArgs: [personId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<void> upsertHistoria(int personId, Map<String, dynamic> data) async {
    final db = _ensureDb();
    final row = {
      'character_id': personId,
      'personality_traits': data['personality_traits'] ?? '',
      'ideals': data['ideals'] ?? '',
      'bonds': data['bonds'] ?? '',
      'flaws': data['flaws'] ?? '',
      'journal': data['journal'] ?? '',
    };
    await db.insert(
      'character_history',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== MAGIC =====
  Future<Map<String, dynamic>?> getCharacterMagic(int characterId) async {
    final db = _ensureDb();
    final res = await db.query(
      'character_magic',
      where: 'character_id = ?',
      whereArgs: [characterId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<void> upsertCharacterMagic(
    int characterId, {
    String? magicAbility,
    int? saveDc,
    int? attackBonus,
  }) async {
    final db = _ensureDb();
    final row = {
      'character_id': characterId,
      'magic_ability': magicAbility,
      'save_dc': saveDc,
      'attack_bonus': attackBonus,
    };
    await db.insert(
      'character_magic',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== STATS =====
  Future<Map<String, dynamic>?> getCharacterStats(int characterId) async {
    final db = _ensureDb();
    final res = await db.query(
      'character_stats',
      where: 'character_id = ?',
      whereArgs: [characterId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<void> upsertCharacterStats(
    int characterId, {
    int? strScore,
    int? strMod,
    int? dexScore,
    int? dexMod,
    int? conScore,
    int? conMod,
    int? intScore,
    int? intMod,
    int? wisScore,
    int? wisMod,
    int? chaScore,
    int? chaMod,
    int? inspiration,
    int? proficiencyBonus,
  }) async {
    final db = _ensureDb();
    final row = {
      'character_id': characterId,
      'str_score': strScore,
      'str_mod': strMod,
      'dex_score': dexScore,
      'dex_mod': dexMod,
      'con_score': conScore,
      'con_mod': conMod,
      'int_score': intScore,
      'int_mod': intMod,
      'wis_score': wisScore,
      'wis_mod': wisMod,
      'cha_score': chaScore,
      'cha_mod': chaMod,
      'inspiration': inspiration,
      'proficiency_bonus': proficiencyBonus,
    };
    await db.insert(
      'character_stats',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== SPELL SLOTS =====
  Future<List<Map<String, dynamic>>> getSpellSlotsForCharacter(
    int characterId,
  ) async {
    final db = _ensureDb();
    return db.query(
      'spell_slots',
      where: 'character_id = ?',
      whereArgs: [characterId],
      orderBy: 'level ASC',
    );
  }

  Future<void> upsertSpellSlot(
    int characterId,
    int level, {
    required int maxSlots,
    required int usedSlots,
  }) async {
    final db = _ensureDb();
    final row = {
      'character_id': characterId,
      'level': level,
      'max_slots': maxSlots,
      'used_slots': usedSlots,
    };
    await db.insert(
      'spell_slots',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== CHARACTER SPELLS =====
  Future<List<Map<String, dynamic>>> getSpellsByCharacterAndLevel(
    int characterId,
    int level,
  ) async {
    final db = _ensureDb();
    return db.query(
      'character_spells',
      where: 'character_id = ? AND level = ?',
      whereArgs: [characterId, level],
      orderBy: 'id ASC',
    );
  }

  Future<int> insertSpell({
    required int characterId,
    required int level,
    required String name,
    required String description,
  }) async {
    final db = _ensureDb();
    return db.insert('character_spells', {
      'character_id': characterId,
      'level': level,
      'name': name,
      'description': description,
      'known': 1,
    });
  }

  Future<void> updateSpellKnown(int spellId, bool known) async {
    final db = _ensureDb();
    await db.update(
      'character_spells',
      {'known': known ? 1 : 0},
      where: 'id = ?',
      whereArgs: [spellId],
    );
  }

  Future<void> updateSpellDescription(int spellId, String description) async {
    final db = _ensureDb();
    await db.update(
      'character_spells',
      {'description': description},
      where: 'id = ?',
      whereArgs: [spellId],
    );
  }
}
