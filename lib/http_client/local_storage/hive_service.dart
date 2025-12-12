import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _userBox = 'userBox';
  static const String _settingsBox = 'settingsBox';
  static const String _itemsBox = 'itemsBox';
  static const String _clientsBox = 'clientsBox';
  static const String _salesBox = 'salesBox';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await _openBoxes();
  }

  // Open all necessary boxes
  static Future<void> _openBoxes() async {
    await Hive.openBox(_userBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_itemsBox);
    await Hive.openBox(_clientsBox);
    await Hive.openBox(_salesBox);
  }

  // Generic methods for CRUD operations

  // Store data
  static Future<void> storeData(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  // Retrieve data
  static dynamic getData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }

  // Delete data
  static Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  // Clear box
  static Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  // Check if key exists
  static bool hasData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.containsKey(key);
  }

  // Get all keys in a box
  static List<dynamic> getAllKeys(String boxName) {
    final box = Hive.box(boxName);
    return box.keys.toList();
  }

  // Get all values in a box
  static List<dynamic> getAllValues(String boxName) {
    final box = Hive.box(boxName);
    return box.values.toList();
  }

  // Get a whole box as a map
  static Map<String, dynamic> getBox(String boxName) {
    final box = Hive.box(boxName);
    return Map<String, dynamic>.from(box.toMap());
  }

  // Generic getValue and setValue methods (work across all boxes)
  static Future<void> setValue(String key, dynamic value) async {
    // Default to salesBox for generic operations
    await storeData(_salesBox, key, value);
  }

  static dynamic getValue(String key) {
    // Default to salesBox for generic operations
    return getData(_salesBox, key);
  }

  // Specific methods for common boxes

  // User data
  static Future<void> storeUserData(String key, dynamic value) async {
    await storeData(_userBox, key, value);
  }

  static dynamic getUserData(String key) {
    return getData(_userBox, key);
  }

  // Settings
  static Future<void> storeSetting(String key, dynamic value) async {
    await storeData(_settingsBox, key, value);
  }

  static dynamic getSetting(String key) {
    return getData(_settingsBox, key);
  }

  // Items
  static Future<void> storeItem(String key, dynamic value) async {
    await storeData(_itemsBox, key, value);
  }

  static dynamic getItem(String key) {
    return getData(_itemsBox, key);
  }

  // Clients
  static Future<void> storeClient(String key, dynamic value) async {
    await storeData(_clientsBox, key, value);
  }

  static dynamic getClient(String key) {
    return getData(_clientsBox, key);
  }

  static List<dynamic> getAllClients() {
    return getAllValues(_clientsBox);
  }

  // Sales
  static Future<void> storeSale(String key, dynamic value) async {
    await storeData(_salesBox, key, value);
  }

  static dynamic getSale(String key) {
    return getData(_salesBox, key);
  }

  static List<dynamic> getAllSales() {
    return getAllValues(_salesBox);
  }

  // Delete value from storage
  static Future<void> deleteValue(String key) async {
    await deleteData(_salesBox, key);
  }

  // Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }
}
