import 'package:shared_preferences/shared_preferences.dart';

/// Local, device-only account system — no backend required, matching the
/// app's offline-first approach. One trader profile per device.
///
/// NOTE: password is stored in plain text in local storage for simplicity.
/// This is fine for a local demo/single-device tool, but if you connect a
/// real backend later, replace this with proper hashed/server-side auth.
class AuthService {
  static const _onboardingKey = 'sokolink_onboarding_seen_v1';
  static const _shopNameKey = 'sokolink_shop_name_v1';
  static const _phoneKey = 'sokolink_phone_v1';
  static const _passwordKey = 'sokolink_password_v1';
  static const _loggedInKey = 'sokolink_logged_in_v1';

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_phoneKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<String?> getShopName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shopNameKey);
  }

  /// Creates the local account. Returns an error message, or null on success.
  static Future<String?> register({
    required String shopName,
    required String phone,
    required String password,
  }) async {
    if (shopName.trim().isEmpty) return 'Enter your shop name.';
    if (phone.trim().length < 9) return 'Enter a valid phone number.';
    if (password.length < 4) return 'Password must be at least 4 characters.';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shopNameKey, shopName.trim());
    await prefs.setString(_phoneKey, phone.trim());
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_loggedInKey, true);
    return null;
  }

  /// Checks credentials against the local account. Returns an error
  /// message, or null on success.
  static Future<String?> login({required String phone, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString(_phoneKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedPhone == null) {
      return 'No account found on this device. Please register first.';
    }
    if (savedPhone != phone.trim() || savedPassword != password) {
      return 'Incorrect phone number or password.';
    }
    await prefs.setBool(_loggedInKey, true);
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }
}
