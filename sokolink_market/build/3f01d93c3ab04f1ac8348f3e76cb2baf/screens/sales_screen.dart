import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models.dart';
import '../utils.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Product? _selectedProduct;
  final _qtyCtrl = TextEditingController(text: '1');
  final _momoRefCtrl = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  String _momoNetwork = 'MTN';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    AppData.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppData.instance.removeListener(_refresh);
    _qtyCtrl.dispose();
    _momoRefCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  double get _lineTotal {
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    return _selectedProduct == null ? 0 : qty * _selectedProduct!.unitPrice;
  }

  Future<void> _submit() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a product first')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final qty = int.parse(_qtyCtrl.text);
    final error = await AppData.instance.recordSale(
      product: _selectedProduct!,
      quantity: qty,
      paymentMethod: _method,
      momoNetwork: _momoNetwork,
      momoReference: _momoRefCtrl.text,
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sale recorded: ${cedis.format(_lineTotal)}'), backgroundColor: Colors.green),
    );
    setState(() {
      _selectedProduct = null;
      _qtyCtrl.text = '1';
      _momoRefCtrl.clear();
      _method = PaymentMethod.cash;
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = AppData.instance.products.where((p) => p.quantity > 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final sales = AppData.instance.sales;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Record a Sale', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Product>(
                    initialValue: _selectedProduct,
                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                    items: products
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.name} (${p.quantity} in stock)'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProduct = v),
                    validator: (v) => v == null ? 'Select a product' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Quantity sold', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter a valid quantity';
                      if (_selectedProduct != null && n > _selectedProduct!.quantity) return 'Not enough stock';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Payment Method', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  SegmentedButton<PaymentMethod>(
                    segments: const [
                      ButtonSegment(value: PaymentMethod.cash, label: Text('Cash'), icon: Icon(Icons.money)),
                      ButtonSegment(value: PaymentMethod.momo, label: Text('MoMo'), icon: Icon(Icons.phone_android)),
                    ],
                    selected: {_method},
                    onSelectionChanged: (s) => setState(() => _method = s.first),
                  ),
                  if (_method == PaymentMethod.momo) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _momoNetwork,
                      decoration: const InputDecoration(labelText: 'MoMo Network', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'MTN', child: Text('MTN MoMo')),
                        DropdownMenuItem(value: 'Telecel', child: Text('Telecel Cash')),
                        DropdownMenuItem(value: 'AirtelTigo', child: Text('AirtelTigo Money')),
                      ],
                      onChanged: (v) => setState(() => _momoNetwork = v ?? 'MTN'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _momoRefCtrl,
                      decoration: const InputDecoration(
                        labelText: 'MoMo Transaction Reference',
                        hintText: 'e.g. 8842910023',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (_method == PaymentMethod.momo && (v == null || v.trim().isEmpty)) {
                          return 'Enter the MoMo reference';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ${cedis.format(_lineTotal)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check),
                        label: const Text('Record Sale'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Recent Sales', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (sales.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No sales recorded yet.')))
        else
          ...sales.map((s) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        s.paymentMethod == PaymentMethod.cash ? Colors.green.shade100 : Colors.deepPurple.shade100,
                    child: Icon(
                      s.paymentMethod == PaymentMethod.cash ? Icons.money : Icons.phone_android,
                      color: s.paymentMethod == PaymentMethod.cash ? Colors.green : Colors.deepPurple,
                    ),
                  ),
                  title: Text('${s.productName} x${s.quantity}'),
                  subtitle: Text(
                    s.paymentMethod == PaymentMethod.momo
                        ? '${s.momoNetwork} • Ref: ${s.momoReference} • ${formatDateTime(s.timestamp)}'
                        : 'Cash • ${formatDateTime(s.timestamp)}',
                  ),
                  trailing: Text(cedis.format(s.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
      ],
    );
  }
}
