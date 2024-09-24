import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // set string values in shared pref
  static Future<void> setStringValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Shared Pref 1: ${prefs}');
    prefs.setString(key, value);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Shared Pref 2: ${prefs}');
    prefs.setStringList(key, value);
  }

  static Future<List<String>> getStringList(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    log('Shared Pref 3: ${pref}');
    return pref.getStringList(key) ?? [];
  }

  // get string values in shared pref
  static Future<String> getStringValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final loginData = pref.getString(key) ?? "";
    log('Shared Pref 4: ${loginData}');
    return loginData;
    //return pref.getString(key) ?? "";
  }

  // set bool values in shared pref
  static Future<void> setBoolValue(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Shared Pref 5: ${prefs}');
    prefs.setBool(key, value);
  }

  // get bool values in shared pref
  static Future<bool> getBoolValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    log('Shared Pref 6: ${pref}');
    return pref.getBool(key) ?? false;
  }

  // set int values in shared pref
  static Future<void> setIntValue(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Shared Pref 7: ${prefs}');
    prefs.setInt(key, value);
  }

  // get int values in shared pref
  static Future<int> getIntValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    log('Shared Pref 8: ${pref}');
    return pref.getInt(key) ?? 0;
  }

  // set long values in shared pref
  static Future<void> setDoubleValue(String key, double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('Shared Pref 9: ${prefs}');
    prefs.setDouble(key, value);
  }

  // get long values in shared pref
  static Future<double> getDoubleValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    log('Shared Pref 10: ${pref}');
    return pref.getDouble(key) ?? 0.0;
  }

  // get long values in shared pref
  static Future<double> getDoubleValueFont(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    log('Shared Pref 11: ${pref}');
    return pref.getDouble(key) ?? 1.0;
  }

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    log('Shared Pref 12: ${prefs}');
    return prefs.remove(key);
  }

  static Future<bool> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    log('Shared Pref 13: ${prefs}');
    return prefs.clear();
  }
}
