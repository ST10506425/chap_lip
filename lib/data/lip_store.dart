import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import '../models/user_profile.dart';
import 'password_hasher.dart';

/// Thrown when an account action cannot be completed.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Everything the app keeps on the phone: accounts, the signed in session,
/// every lip application and the products each person has unlocked.
abstract class LipStore {
  Future<UserProfile?> restoreSession();
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<UserProfile> logIn({required String email, required String password});
  Future<void> logOut();
  Future<void> resetPassword({required String email, required String name, required String newPassword});
  Future<UserProfile> updateProfile(UserProfile profile, {String? newPassword});
  Future<LipStats> loadStats(int userId);

  /// Records one application and returns the products it unlocked.
  Future<List<Product>> recordApplication(int userId, String productId);
}

/// SQLite backed [LipStore] using sqflite.
class SqliteLipStore implements LipStore {
  SqliteLipStore(this._db);

  final Database _db;

  static const _dbName = 'moist_me_up.db';
  static const _version = 1;

  static Future<SqliteLipStore> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), _dbName);
    final db = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => _createSchema(db),
      ),
    );
    return SqliteLipStore(db);
  }

  static Future<void> _createSchema(Database db) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        gender TEXT,
        lip_shape TEXT NOT NULL DEFAULT 'full',
        lip_shade TEXT NOT NULL DEFAULT 'rose',
        active_product TEXT NOT NULL DEFAULT 'vaseline',
        onboarded INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        token TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        last_seen_at INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        product_id TEXT NOT NULL,
        applied_at INTEGER NOT NULL
      )''');
    batch.execute('CREATE INDEX idx_applications_user ON applications(user_id)');
    batch.execute('''
      CREATE TABLE unlocks (
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        product_id TEXT NOT NULL,
        unlocked_at INTEGER NOT NULL,
        PRIMARY KEY (user_id, product_id)
      )''');
    await batch.commit(noResult: true);
  }

  Future<void> close() => _db.close();

  int get _now => DateTime.now().millisecondsSinceEpoch;

  Future<UserProfile?> _userById(int id) async {
    final rows = await _db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : UserProfile.fromRow(rows.first);
  }

  Future<void> _startSession(int userId) async {
    await _db.insert(
      'sessions',
      {
        'id': 1,
        'user_id': userId,
        'token': PasswordHasher.newToken(),
        'started_at': _now,
        'last_seen_at': _now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserProfile?> restoreSession() async {
    final rows = await _db.query('sessions', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    final userId = rows.first['user_id'] as int;
    await _db.update('sessions', {'last_seen_at': _now}, where: 'id = 1');
    return _userById(userId);
  }

  @override
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final existing = await _db.query('users', where: 'email = ?', whereArgs: [cleanEmail], limit: 1);
    if (existing.isNotEmpty) {
      throw const AuthException('That email already has lips on this phone. Try logging in.');
    }
    final salt = PasswordHasher.newSalt();
    final id = await _db.transaction((txn) async {
      final id = await txn.insert('users', {
        'name': name.trim(),
        'email': cleanEmail,
        'password_hash': PasswordHasher.hash(password, salt),
        'salt': salt,
        'created_at': _now,
      });
      await txn.insert('unlocks', {
        'user_id': id,
        'product_id': Product.vaseline.id,
        'unlocked_at': _now,
      });
      return id;
    });
    await _startSession(id);
    return (await _userById(id))!;
  }

  @override
  Future<UserProfile> logIn({required String email, required String password}) async {
    final rows = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AuthException('We could not find those lips. Check your email.');
    }
    final row = rows.first;
    final ok = PasswordHasher.verify(password, row['salt'] as String, row['password_hash'] as String);
    if (!ok) throw const AuthException('That password does not match. Try again.');
    final id = row['id'] as int;
    await _startSession(id);
    return UserProfile.fromRow(row);
  }

  @override
  Future<void> logOut() => _db.delete('sessions');

  @override
  Future<void> resetPassword({
    required String email,
    required String name,
    required String newPassword,
  }) async {
    final rows = await _db.query(
      'users',
      where: 'email = ? AND name = ? COLLATE NOCASE',
      whereArgs: [email.trim().toLowerCase(), name.trim()],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AuthException('That name and email do not match an account on this phone.');
    }
    final salt = PasswordHasher.newSalt();
    await _db.update(
      'users',
      {'salt': salt, 'password_hash': PasswordHasher.hash(newPassword, salt)},
      where: 'id = ?',
      whereArgs: [rows.first['id']],
    );
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile, {String? newPassword}) async {
    final cleanEmail = profile.email.trim().toLowerCase();
    final clash = await _db.query(
      'users',
      where: 'email = ? AND id != ?',
      whereArgs: [cleanEmail, profile.id],
      limit: 1,
    );
    if (clash.isNotEmpty) {
      throw const AuthException('Another account on this phone already uses that email.');
    }
    final values = <String, Object?>{
      'name': profile.name.trim(),
      'email': cleanEmail,
      'gender': profile.gender,
      'lip_shape': profile.lipShape.name,
      'lip_shade': profile.lipShade.id,
      'active_product': profile.activeProductId,
      'onboarded': profile.onboarded ? 1 : 0,
    };
    if (newPassword != null && newPassword.isNotEmpty) {
      final salt = PasswordHasher.newSalt();
      values['salt'] = salt;
      values['password_hash'] = PasswordHasher.hash(newPassword, salt);
    }
    await _db.update('users', values, where: 'id = ?', whereArgs: [profile.id]);
    return (await _userById(profile.id))!;
  }

  @override
  Future<LipStats> loadStats(int userId) async {
    final count = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM applications WHERE user_id = ?', [userId]),
        ) ??
        0;
    final unlockRows = await _db.query('unlocks', columns: ['product_id'], where: 'user_id = ?', whereArgs: [userId]);
    final usedRows = await _db.rawQuery(
      'SELECT DISTINCT product_id FROM applications WHERE user_id = ?',
      [userId],
    );
    final dayRows = await _db.rawQuery(
      "SELECT DISTINCT date(applied_at / 1000, 'unixepoch', 'localtime') AS day "
      'FROM applications WHERE user_id = ? ORDER BY day DESC',
      [userId],
    );
    return LipStats(
      applications: count,
      unlocked: {Product.vaseline.id, ...unlockRows.map((r) => r['product_id'] as String)},
      usedProducts: usedRows.map((r) => r['product_id'] as String).toSet(),
      streakDays: _streak(dayRows.map((r) => r['day'] as String).toList()),
    );
  }

  static int _streak(List<String> daysDescending) {
    if (daysDescending.isEmpty) return 0;
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    final first = DateTime.parse(daysDescending.first);
    if (cursor.difference(first).inDays > 1) return 0;
    if (cursor.difference(first).inDays == 1) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    for (final day in daysDescending) {
      if (DateTime.parse(day) == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Future<List<Product>> recordApplication(int userId, String productId) {
    return _db.transaction((txn) async {
      await txn.insert('applications', {
        'user_id': userId,
        'product_id': productId,
        'applied_at': _now,
      });
      final total = Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM applications WHERE user_id = ?', [userId]),
          ) ??
          0;
      final owned = (await txn.query('unlocks', columns: ['product_id'], where: 'user_id = ?', whereArgs: [userId]))
          .map((r) => r['product_id'] as String)
          .toSet();
      final fresh = Product.catalog.where((p) => !owned.contains(p.id) && total >= p.unlockAt).toList();
      for (final product in fresh) {
        await txn.insert(
          'unlocks',
          {'user_id': userId, 'product_id': product.id, 'unlocked_at': _now},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      return fresh;
    });
  }
}

