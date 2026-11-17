import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _key = 'username';

  static Future<void> login(String username) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, username);
  }

  static Future<String?> getUsername() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_key);
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
