import 'package:flutter/material.dart';
import '../app_data.dart';
import '../utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final data = AppData.instance;
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2,
                  label: 'Inventory Value',
                  value: cedis.format(data.totalInventoryValue),
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.today,
                  label: "Today's Sales",
                  value: cedis.format(data.todaysTotal),
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.money,
                  label: 'Cash Today',
                  value: cedis.format(data.todaysCash),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.phone_android,
                  label: 'MoMo Today',
                  value: cedis.format(data.todaysMomo),
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (data.pendingSyncCount > 0)
            Card(
              color: Colors.amber.shade50,
              child: ListTile(
                leading: const Icon(Icons.cloud_off, color: Colors.orange),
                title: Text('${data.pendingSyncCount} item(s) waiting to sync'),
                subtitle: const Text('Your data is safe locally. Sync when you have data/wifi.'),
              ),
            ),
          const SizedBox(height: 12),
          Text('Low Stock Alerts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (data.lowStockProducts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No low stock items. All good! ✅'),
              ),
            )
          else
            ...data.lowStockProducts.map(
              (p) => Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.red),
                  title: Text(p.name),
                  subtitle: Text('${p.category} • Only ${p.quantity} left'),
                  trailing: Text(cedis.format(p.unitPrice)),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text('Recent Sales', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (data.sales.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No sales recorded yet.'),
              ),
            )
          else
            ...data.sales.take(5).map(
                  (s) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            s.paymentMethod.name == 'cash' ? Colors.green.shade100 : Colors.deepPurple.shade100,
                        child: Icon(
                          s.paymentMethod.name == 'cash' ? Icons.money : Icons.phone_android,
                          color: s.paymentMethod.name == 'cash' ? Colors.green : Colors.deepPurple,
                        ),
                      ),
                      title: Text('${s.productName} x${s.quantity}'),
                      subtitle: Text(formatDateTime(s.timestamp)),
                      trailing: Text(cedis.format(s.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
