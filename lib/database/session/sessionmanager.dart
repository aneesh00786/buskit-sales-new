
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> setStringValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
  static Future<String> getStringValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final loginData = pref.getString(key) ?? "";
    return loginData;
  }
  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
  static Future<bool> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    final cleared = await prefs.clear();
    await SharedPreferences.getInstance();
    await prefs.reload();
    return cleared;
  }
}
