import 'package:shared_preferences/shared_preferences.dart';

/// เก็บ credential สำหรับ "จดจำบัญชีผู้ใช้" — ตาม user-app
class LocalStorageService {
  static const _kUsername = 'saved_username';
  static const _kPassword = 'saved_password';

  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, username);
    await prefs.setString(_kPassword, password);
  }

  static Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_kUsername);
    final password = prefs.getString(_kPassword);
    if (username == null || username.isEmpty) return {};
    return {'username': username, 'password': password ?? ''};
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsername);
    await prefs.remove(_kPassword);
  }
}
