import 'package:flutter/material.dart';
import 'app_data.dart';
import 'auth_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/sync_screen.dart';

void main() {
  runApp(const SokoLinkApp());
}

class SokoLinkApp extends StatelessWidget {
  const SokoLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SokoLink Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}

enum _AppPhase { loading, onboarding, login, register, home }

/// Top-level state machine: onboarding (first launch only) -> login/register
/// (local, device-only account) -> home (the actual tracker).
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _AppPhase _phase = _AppPhase.loading;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final onboardingSeen = await AuthService.isOnboardingSeen();
    if (!onboardingSeen) {
      setState(() => _phase = _AppPhase.onboarding);
      return;
    }
    await _goToAuthOrHome();
  }

  Future<void> _goToAuthOrHome() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      await AppData.instance.load();
      if (!mounted) return;
      setState(() => _phase = _AppPhase.home);
    } else {
      final hasAccount = await AuthService.hasAccount();
      if (!mounted) return;
      setState(() => _phase = hasAccount ? _AppPhase.login : _AppPhase.register);
    }
  }

  Future<void> _completeOnboarding() async {
    await AuthService.setOnboardingSeen();
    await _goToAuthOrHome();
  }

  Future<void> _onAuthSuccess() async {
    await AppData.instance.load();
    if (!mounted) return;
    setState(() => _phase = _AppPhase.home);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    setState(() => _phase = _AppPhase.login);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _AppPhase.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case _AppPhase.onboarding:
        return OnboardingScreen(onDone: _completeOnboarding);
      case _AppPhase.login:
        return LoginScreen(
          onLoggedIn: _onAuthSuccess,
          onRegisterTap: () => setState(() => _phase = _AppPhase.register),
        );
      case _AppPhase.register:
        return RegisterScreen(
          onRegistered: _onAuthSuccess,
          onLoginTap: () => setState(() => _phase = _AppPhase.login),
        );
      case _AppPhase.home:
        return HomeShell(onLogout: _logout);
    }
  }
}

class HomeShell extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeShell({super.key, required this.onLogout});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  String? _shopName;

  @override
  void initState() {
    super.initState();
    AuthService.getShopName().then((name) {
      if (mounted) setState(() => _shopName = name);
    });
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your data stays saved on this device. You can log back in anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      DashboardScreen(),
      InventoryScreen(),
      SalesScreen(),
      SyncScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_shopName == null || _shopName!.isEmpty ? 'SokoLink Market' : _shopName!),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.sync_outlined), selectedIcon: Icon(Icons.sync), label: 'Sync'),
        ],
      ),
    );
  }
}
