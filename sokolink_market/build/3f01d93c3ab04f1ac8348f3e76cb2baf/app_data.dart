import 'package:flutter/foundation.dart';
import 'models.dart';
import 'storage_service.dart';

/// Single in-memory source of truth for the whole app. Screens listen to
/// this via AnimatedBuilder so any change (add stock, record a sale, sync)
/// is reflected everywhere immediately, while every mutation is also
/// persisted to local storage so nothing is lost if the tab/app is closed.
class AppData extends ChangeNotifier {
  AppData._internal();
  static final AppData instance = AppData._internal();

  List<Product> products = [];
  List<Sale> sales = [];
  DateTime? lastSync;
  bool loaded = false;

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> load() async {
    products = await StorageService.loadProducts();
    sales = await StorageService.loadSales();
    lastSync = await StorageService.getLastSync();
    loaded = true;
    notifyListeners();
  }

  int get pendingSyncCount =>
      products.where((p) => !p.synced).length + sales.where((s) => !s.synced).length;

  double get totalInventoryValue =>
      products.fold(0.0, (sum, p) => sum + (p.quantity * p.unitPrice));

  List<Product> get lowStockProducts => products.where((p) => p.isLowStock).toList();

  List<Sale> get todaysSales {
    final now = DateTime.now();
    return sales
        .where((s) =>
            s.timestamp.year == now.year &&
            s.timestamp.month == now.month &&
            s.timestamp.day == now.day)
        .toList();
  }

  double get todaysTotal => todaysSales.fold(0.0, (sum, s) => sum + s.total);
  double get todaysCash => todaysSales
      .where((s) => s.paymentMethod == PaymentMethod.cash)
      .fold(0.0, (sum, s) => sum + s.total);
  double get todaysMomo => todaysSales
      .where((s) => s.paymentMethod == PaymentMethod.momo)
      .fold(0.0, (sum, s) => sum + s.total);

  Future<void> addProduct({
    required String name,
    required String category,
    required int quantity,
    required double unitPrice,
    required int lowStockThreshold,
  }) async {
    products.add(Product(
      id: _newId(),
      name: name,
      category: category,
      quantity: quantity,
      unitPrice: unitPrice,
      lowStockThreshold: lowStockThreshold,
    ));
    await StorageService.saveProducts(products);
    notifyListeners();
  }

  Future<void> updateProduct(Product updated) async {
    final idx = products.indexWhere((p) => p.id == updated.id);
    if (idx == -1) return;
    updated.synced = false;
    updated.updatedAt = DateTime.now();
    products[idx] = updated;
    await StorageService.saveProducts(products);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    products.removeWhere((p) => p.id == id);
    await StorageService.saveProducts(products);
    notifyListeners();
  }

  /// Records a sale, deducts the sold quantity from stock, and marks both
  /// records as pending sync. Returns an error message, or null on success.
  Future<String?> recordSale({
    required Product product,
    required int quantity,
    required PaymentMethod paymentMethod,
    String? momoNetwork,
    String? momoReference,
  }) async {
    if (quantity <= 0) return 'Quantity must be greater than zero.';
    if (quantity > product.quantity) return 'Not enough stock available.';
    if (paymentMethod == PaymentMethod.momo &&
        (momoReference == null || momoReference.trim().isEmpty)) {
      return 'Please enter the MoMo transaction reference.';
    }

    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx == -1) return 'Product no longer exists.';
    products[idx].quantity -= quantity;
    products[idx].synced = false;
    products[idx].updatedAt = DateTime.now();

    sales.insert(
      0,
      Sale(
        id: _newId(),
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: product.unitPrice,
        paymentMethod: paymentMethod,
        momoNetwork: paymentMethod == PaymentMethod.momo ? momoNetwork : null,
        momoReference: paymentMethod == PaymentMethod.momo ? momoReference?.trim() : null,
      ),
    );

    await StorageService.saveProducts(products);
    await StorageService.saveSales(sales);
    notifyListeners();
    return null;
  }

  /// Simulates pushing local changes to a server. Swap the delay below for
  /// a real API/backend call when you're ready to add one.
  Future<void> syncNow() async {
    await Future.delayed(const Duration(milliseconds: 900));
    for (final p in products) {
      p.synced = true;
    }
    for (final s in sales) {
      s.synced = true;
    }
    lastSync = DateTime.now();
    await StorageService.saveProducts(products);
    await StorageService.saveSales(sales);
    await StorageService.setLastSync(lastSync!);
    notifyListeners();
  }
}
