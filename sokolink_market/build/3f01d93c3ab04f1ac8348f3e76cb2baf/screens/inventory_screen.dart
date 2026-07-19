import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models.dart';
import '../utils.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    AppData.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppData.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final products = AppData.instance.products
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products yet. Tap + to add stock.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return Card(
                        color: p.isLowStock ? Colors.red.shade50 : null,
                        child: ListTile(
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${p.category} • Qty: ${p.quantity} • ${cedis.format(p.unitPrice)} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!p.synced)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.cloud_off, size: 18, color: Colors.orange),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showProductDialog(product: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmDelete(p),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Stock'),
      ),
    );
  }

  void _confirmDelete(Product p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${p.name}" from inventory? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              AppData.instance.deleteProduct(p.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showProductDialog({Product? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? '');
    final qtyCtrl = TextEditingController(text: product?.quantity.toString() ?? '');
    final priceCtrl = TextEditingController(text: product?.unitPrice.toString() ?? '');
    final thresholdCtrl = TextEditingController(text: (product?.lowStockThreshold ?? 5).toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category (e.g. Foodstuff, Textiles)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity in stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a valid number' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Unit price (GH₵)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Enter a valid price' : null,
                ),
                TextFormField(
                  controller: thresholdCtrl,
                  decoration: const InputDecoration(labelText: 'Low stock alert threshold'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a valid number' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtrl.text.trim();
              final category = categoryCtrl.text.trim();
              final qty = int.parse(qtyCtrl.text);
              final price = double.parse(priceCtrl.text);
              final threshold = int.parse(thresholdCtrl.text);

              if (isEdit) {
                AppData.instance.updateProduct(Product(
                  id: product.id,
                  name: name,
                  category: category,
                  quantity: qty,
                  unitPrice: price,
                  lowStockThreshold: threshold,
                  synced: product.synced,
                ));
              } else {
                AppData.instance.addProduct(
                  name: name,
                  category: category,
                  quantity: qty,
                  unitPrice: price,
                  lowStockThreshold: threshold,
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
}
