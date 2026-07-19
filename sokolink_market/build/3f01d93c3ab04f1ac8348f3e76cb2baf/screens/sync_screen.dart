import 'package:flutter/material.dart';
import '../app_data.dart';
import '../utils.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _syncing = false;

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

  Future<void> _sync() async {
    setState(() => _syncing = true);
    await AppData.instance.syncNow();
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synced successfully'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final unsyncedProducts = data.products.where((p) => !p.synced).toList();
    final unsyncedSales = data.sales.where((s) => !s.synced).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  data.pendingSyncCount == 0 ? Icons.cloud_done : Icons.cloud_off,
                  size: 48,
                  color: data.pendingSyncCount == 0 ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 12),
                Text(
                  data.pendingSyncCount == 0
                      ? 'Everything is synced'
                      : '${data.pendingSyncCount} item(s) waiting to sync',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text('Last sync: ${formatTimeAgo(data.lastSync)}', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _syncing ? null : _sync,
                  icon: _syncing
                      ? const SizedBox(
                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync),
                  label: Text(_syncing ? 'Syncing...' : 'Sync Now'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This app works fully offline — all stock and sales data is saved on this device. '
                    'Tap "Sync Now" whenever you have data/wifi to back everything up.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (unsyncedProducts.isNotEmpty) ...[
          Text('Pending Products (${unsyncedProducts.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...unsyncedProducts.map((p) => Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.orange),
                  title: Text(p.name),
                  subtitle: Text('Updated ${formatDateTime(p.updatedAt)}'),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (unsyncedSales.isNotEmpty) ...[
          Text('Pending Sales (${unsyncedSales.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...unsyncedSales.map((s) => Card(
                child: ListTile(
                  leading: const Icon(Icons.point_of_sale, color: Colors.orange),
                  title: Text('${s.productName} x${s.quantity}'),
                  subtitle: Text(formatDateTime(s.timestamp)),
                  trailing: Text(cedis.format(s.total)),
                ),
              )),
        ],
      ],
    );
  }
}
