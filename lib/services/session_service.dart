import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class SessionService {
  static const String _rememberedUserIdKey = 'remembered_user_id';

  static Future<void> rememberUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_rememberedUserIdKey, user.id);
  }

  static Future<String?> getRememberedUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_rememberedUserIdKey);
  }

  static Future<void> clearRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_rememberedUserIdKey);
  }
}
