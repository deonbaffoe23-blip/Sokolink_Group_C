class Product {
  String id;
  String name;
  String category;
  int quantity;
  double unitPrice;
  int lowStockThreshold;
  bool synced;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    this.lowStockThreshold = 5,
    this.synced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool get isLowStock => quantity <= lowStockThreshold;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'lowStockThreshold': lowStockThreshold,
        'synced': synced,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String? ?? 'General',
        quantity: (j['quantity'] as num).toInt(),
        unitPrice: (j['unitPrice'] as num).toDouble(),
        lowStockThreshold: (j['lowStockThreshold'] as num?)?.toInt() ?? 5,
        synced: j['synced'] as bool? ?? false,
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

enum PaymentMethod { cash, momo }

class Sale {
  String id;
  String productId;
  String productName;
  int quantity;
  double unitPrice;
  double get total => quantity * unitPrice;
  PaymentMethod paymentMethod;
  String? momoNetwork; // MTN, Telecel, AirtelTigo
  String? momoReference;
  DateTime timestamp;
  bool synced;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.paymentMethod,
    this.momoNetwork,
    this.momoReference,
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'paymentMethod': paymentMethod.name,
        'momoNetwork': momoNetwork,
        'momoReference': momoReference,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory Sale.fromJson(Map<String, dynamic> j) => Sale(
        id: j['id'] as String,
        productId: j['productId'] as String,
        productName: j['productName'] as String,
        quantity: (j['quantity'] as num).toInt(),
        unitPrice: (j['unitPrice'] as num).toDouble(),
        paymentMethod: (j['paymentMethod'] == 'momo') ? PaymentMethod.momo : PaymentMethod.cash,
        momoNetwork: j['momoNetwork'] as String?,
        momoReference: j['momoReference'] as String?,
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
        synced: j['synced'] as bool? ?? false,
      );
}
