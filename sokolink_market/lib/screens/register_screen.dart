import 'package:flutter/material.dart';
import '../auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;
  final VoidCallback onLoginTap;
  const RegisterScreen({super.key, required this.onRegistered, required this.onLoginTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await AuthService.register(
      shopName: _shopNameCtrl.text,
      phone: _phoneCtrl.text,
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    widget.onRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.store_mall_directory_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  const Text('Set Up Your Shop', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Create your local trader account', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 32),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _shopNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Shop Name',
                      hintText: 'e.g. Ama\'s Provisions',
                      prefixIcon: Icon(Icons.storefront_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your shop name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g. 0244000000',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your phone number';
                      if (v.trim().length < 9) return 'Enter a valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.length < 4) ? 'At least 4 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v != _passwordCtrl.text) ? 'Passwords do not match' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onLoginTap,
                    child: const Text('Already have an account? Log In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
