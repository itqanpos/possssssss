import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/index.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;
  static late Box _hiveBox;

  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _settingsKey = 'settings';
  static const String _cartKey = 'cart';
  static const String _offlineDataKey = 'offline_data';

  static Future<void> init() async {
    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();
    _hiveBox = await Hive.openBox('erp_cache');
  }

  // Token
  static String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User
  static User? getUser() {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      return User.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  static Future<void> setUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> removeUser() async {
    await _prefs.remove(_userKey);
  }

  // Settings
  static Map<String, dynamic>? getSettings() {
    final settingsStr = _prefs.getString(_settingsKey);
    if (settingsStr != null) {
      return jsonDecode(settingsStr);
    }
    return null;
  }

  static Future<void> setSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  // Cart (for offline sales)
  static List<Map<String, dynamic>> getCart() {
    final cartStr = _hiveBox.get(_cartKey);
    if (cartStr != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cartStr));
    }
    return [];
  }

  static Future<void> setCart(List<Map<String, dynamic>> cart) async {
    await _hiveBox.put(_cartKey, jsonEncode(cart));
  }

  static Future<void> addToCart(Map<String, dynamic> item) async {
    final cart = getCart();
    cart.add(item);
    await setCart(cart);
  }

  static Future<void> removeFromCart(int index) async {
    final cart = getCart();
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      await setCart(cart);
    }
  }

  static Future<void> clearCart() async {
    await _hiveBox.delete(_cartKey);
  }

  // Offline data
  static List<Map<String, dynamic>> getOfflineData() {
    final dataStr = _hiveBox.get(_offlineDataKey);
    if (dataStr != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(dataStr));
    }
    return [];
  }

  static Future<void> addOfflineData(Map<String, dynamic> data) async {
    final offlineData = getOfflineData();
    offlineData.add({
      ...data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _hiveBox.put(_offlineDataKey, jsonEncode(offlineData));
  }

  static Future<void> removeOfflineData(int index) async {
    final offlineData = getOfflineData();
    if (index >= 0 && index < offlineData.length) {
      offlineData.removeAt(index);
      await _hiveBox.put(_offlineDataKey, jsonEncode(offlineData));
    }
  }

  static Future<void> clearOfflineData() async {
    await _hiveBox.delete(_offlineDataKey);
  }

  // Cache
  static Future<void> setCache(String key, dynamic value) async {
    await _hiveBox.put(key, jsonEncode(value));
  }

  static dynamic getCache(String key) {
    final value = _hiveBox.get(key);
    if (value != null) {
      return jsonDecode(value);
    }
    return null;
  }

  static Future<void> removeCache(String key) async {
    await _hiveBox.delete(key);
  }

  // Products cache
  static Future<void> cacheProducts(List<Product> products) async {
    await setCache('products', products.map((p) => p.toJson()).toList());
  }

  static List<Product>? getCachedProducts() {
    final data = getCache('products');
    if (data != null) {
      return (data as List).map((e) => Product.fromJson(e)).toList();
    }
    return null;
  }

  // Customers cache
  static Future<void> cacheCustomers(List<Customer> customers) async {
    await setCache('customers', customers.map((c) => c.toJson()).toList());
  }

  static List<Customer>? getCachedCustomers() {
    final data = getCache('customers');
    if (data != null) {
      return (data as List).map((e) => Customer.fromJson(e)).toList();
    }
    return null;
  }

  // Clear all
  static Future<void> clearAll() async {
    await _prefs.clear();
    await _hiveBox.clear();
  }

  // Check if logged in
  static bool isLoggedIn() {
    return getToken() != null && getUser() != null;
  }
}
