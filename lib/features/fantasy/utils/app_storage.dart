import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<void> saveToStorageString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<void> saveToStorageBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<String?> getStorageValueString(String keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keys);
  }

  static Future<bool?> getStorageValueBool(String keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keys);
  }

  static Future<bool> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
