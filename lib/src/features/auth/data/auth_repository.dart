import 'package:multiple_result/multiple_result.dart';
import 'package:queue_management_system/src/exceptions/app_exceptions.dart';
import 'package:queue_management_system/src/features/auth/domain/models/admin.dart';
import 'package:queue_management_system/src/core/database/database_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../exceptions/app_exceptions.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper;

  AuthRepository(this._dbHelper);

  Future<bool> _isEmailInUse(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admin',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<void> insertAdmin(Admin admin) async {
    final db = await _dbHelper.database;
    await db.insert('admin', admin.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Result<void, AppException>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'admin',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isEmpty) {
        return Error(UserNotFoundException());
      }

      final admin = Admin.fromMap(maps.first);

      if (admin.password != password) {
        return Error(WrongPasswordException());
      }

      await updateLoginStatus(email, true);
      return const Success(null);
    } catch (e) {
      return Error(UnknownErrorException(e.toString()));
    }
  }

  Future<Result<void, AppException>> createAdminWithEmailAndPassword(
      String email, String password) async {
    try {
      if (await _isEmailInUse(email)) {
        return Error(EmailAlreadyInUseException());
      }

      if (password.length < 8) {
        return Error(WeakPasswordException());
      }

      final newAdmin = Admin(
          id: DateTime.now().toString(), email: email, password: password);
      await insertAdmin(newAdmin);

      return const Success(null);
    } catch (e) {
      return Error(UnknownErrorException(e.toString()));
    }
  }

  Future<List<Admin>> getAdmins() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('admin');
    return maps.map((map) => Admin.fromMap(map)).toList();
  }

  Future<void> updateLoginStatus(String email, bool isLoggedIn) async {
    final db = await _dbHelper.database;
    await db.update(
      'admin',
      {'is_logged_in': isLoggedIn ? 1 : 0},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<String?> getLoggedInAdminEmail() async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(
      'admin',
      columns: ['email'],
      where: 'is_logged_in = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      return result.first['email'] as String;
    }
    return null; // No admin is logged in
  }

  Future<bool> validateCredentials(String email, String password) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admin',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return maps.isNotEmpty;
  }

  Future<void> deleteAdmin(String id) async {
    final db = await _dbHelper.database;
    await db.delete('admin', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> isLoggedIn(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admin',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final admin = Admin.fromMap(maps.first);
      return admin.isLoggedIn ? 1 : 0;
    } else {
      return 0;
    }
  }
}

/// Riverpod Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dbHelper = ref.read(databaseProvider);
  return AuthRepository(dbHelper);
});

final adminListProvider = FutureProvider.autoDispose<List<Admin>>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getAdmins();
});
