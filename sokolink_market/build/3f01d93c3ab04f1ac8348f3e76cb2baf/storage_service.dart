import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// All data is stored locally on-device (via SharedPreferences, which on
/// Flutter web is backed by the browser's localStorage). This means the app
/// works fully offline. "Sync" is a manual step (see AppData.syncNow) that
/// you can later connect to a real backend/API.
class StorageService {
  static const _productsKey = 'sokolink_products_v1';
  static const _salesKey = 'sokolink_sales_v1';
  static const _lastSyncKey = 'sokolink_last_sync_v1';

  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_productsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(products.map((p) => p.toJson()).toList()));
  }

  static Future<List<Sale>> loadSales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_salesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveSales(List<Sale> sales) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_salesKey, jsonEncode(sales.map((s) => s.toJson()).toList()));
  }

  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> setLastSync(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, time.toIso8601String());
  }
}
