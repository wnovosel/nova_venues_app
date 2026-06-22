import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/tenant_config.dart';
import '../api/api_client.dart';

/// Top-level provider. Injected at app root via Provider<AppProvider>.
/// Every screen reaches up to get config, api, and auth state from here.
class AppProvider extends ChangeNotifier {
  final TenantConfig config;
  late final ApiClient api;

  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _user;
  bool _loading = false;
  String? _error;

  AppProvider(this.config) {
    api = ApiClient(config);
    _restoreSession();
  }

  Map<String, dynamic>? get user    => _user;
  bool get isLoggedIn                => _user != null;
  bool get loading                   => _loading;
  String? get error                  => _error;

  Future<void> _restoreSession() async {
    final token = await _storage.read(key: 'nv_access_token');
    if (token != null) {
      api.setToken(token);
      try {
        final me = await api.getMe();
        _user = me['data'] as Map<String, dynamic>?;
      } catch (_) {
        api.clearToken();
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final res = await api.authLogin(email, password);
      final token   = res['access_token']   as String?;
      final refresh = res['refresh_token']  as String?;
      if (token == null) { _error = 'Login failed'; _loading = false; notifyListeners(); return false; }
      api.setToken(token);
      await _storage.write(key: 'nv_access_token',  value: token);
      if (refresh != null) await _storage.write(key: 'nv_refresh_token', value: refresh);
      final me = await api.getMe();
      _user = me['data'] as Map<String, dynamic>?;
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString(); _loading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    api.clearToken();
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final me = await api.getMe();
      _user = me['data'] as Map<String, dynamic>?;
      notifyListeners();
    } catch (_) {}
  }
}
