import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../core/database/app_database.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class User {
  const User({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;
}

/// Local user accounts stored in SQLite.
class UserRepository {
  UserRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const _invalidCredentials = AuthException('Invalid email or password');

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await _database.database;
    final normalizedEmail = _normalizeEmail(email);
    final trimmedName = name.trim();

    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw const AuthException('An account with this email already exists');
    }

    final salt = _generateSalt();
    final id = await db.insert('users', {
      'name': trimmedName,
      'email': normalizedEmail,
      'password_hash': _hash(password, salt),
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });

    return User(id: id, name: trimmedName, email: normalizedEmail);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [_normalizeEmail(email)],
      limit: 1,
    );
    if (rows.isEmpty) throw _invalidCredentials;

    final row = rows.first;
    final hash = _hash(password, row['salt'] as String);
    if (hash != row['password_hash']) throw _invalidCredentials;

    return User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
    );
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Salted SHA-256 is enough for a device-local store. Use a server-side
  // password hash (bcrypt/argon2) once accounts sync to a backend.
  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
