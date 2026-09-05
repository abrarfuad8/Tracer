import '../models/user.dart';
import 'database_helper.dart';

class UserService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<bool> registerUser(User user) async {
    final db = await _databaseHelper.database;

    final existingUsers = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );

    if (existingUsers.isNotEmpty) {
      return false;
    }

    await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
    });

    return true;
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isEmpty) {
      return null;
    }

    final user = result.first;

    return User(
      id: user['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      password: user['password'] as String,
    );
  }
}
