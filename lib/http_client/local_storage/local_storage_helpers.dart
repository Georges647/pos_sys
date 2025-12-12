import 'dart:convert';
import 'hive_service.dart';

class LocalStorageHelpers {
  // Store a JSON object as a string
  static Future<void> storeJson(String boxName, String key, Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    await HiveService.storeData(boxName, key, jsonString);
  }

  // Retrieve a JSON object from storage
  static Map<String, dynamic>? getJson(String boxName, String key) {
    final jsonString = HiveService.getData(boxName, key);
    if (jsonString != null && jsonString is String) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        // Handle invalid JSON
        return null;
      }
    }
    return null;
  }

  // Store a list of JSON objects as a string
  static Future<void> storeJsonList(String boxName, String key, List<Map<String, dynamic>> jsonList) async {
    final jsonString = jsonEncode(jsonList);
    await HiveService.storeData(boxName, key, jsonString);
  }

  // Retrieve a list of JSON objects from storage
  static List<Map<String, dynamic>>? getJsonList(String boxName, String key) {
    final jsonString = HiveService.getData(boxName, key);
    if (jsonString != null && jsonString is String) {
      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is List) {
          return decoded.map((item) => item as Map<String, dynamic>).toList();
        }
      } catch (e) {
        // Handle invalid JSON
        return null;
      }
    }
    return null;
  }

  // Store a simple value with type safety
  static Future<void> storeValue<T>(String boxName, String key, T value) async {
    await HiveService.storeData(boxName, key, value);
  }

  // Retrieve a value with type casting
  static T? getValue<T>(String boxName, String key) {
    final value = HiveService.getData(boxName, key);
    if (value is T) {
      return value;
    }
    return null;
  }

  // Check if a key exists in a box
  static bool hasKey(String boxName, String key) {
    return HiveService.hasData(boxName, key);
  }

  // Remove a key from a box
  static Future<void> removeKey(String boxName, String key) async {
    await HiveService.deleteData(boxName, key);
  }

  // Clear all data in a box
  static Future<void> clearBox(String boxName) async {
    await HiveService.clearBox(boxName);
  }

  // Get all keys in a box
  static List<dynamic> getAllKeys(String boxName) {
    return HiveService.getAllKeys(boxName);
  }

  // Get all values in a box
  static List<dynamic> getAllValues(String boxName) {
    return HiveService.getAllValues(boxName);
  }
}
