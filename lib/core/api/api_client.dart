import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/tenant_config.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final bool isRetryable;
  const ApiException(this.message, {this.statusCode, this.isRetryable = false});
  @override
  String toString() => message;
}

/// Tenant-aware API client.
/// Reads baseUrl and tenantId from TenantConfig — never hardcoded.
/// Sends X-Tenant-ID on every request so the backend scopes to the right tenant.
class ApiClient {
  final TenantConfig config;
  String? _token;

  ApiClient(this.config);

  String get apiBase => '${config.apiBaseUrl}/api/v1';

  void setToken(String token) => _token = token;
  void clearToken()           => _token = null;
  bool get isAuthenticated    => _token != null;

  Map<String, String> get _headers => {
    'Content-Type':  'application/json',
    'Accept':        'application/json',
    'X-Tenant-ID':   config.tenantId,
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Health ─────────────────────────────────────────────────────────────────

  Future<void> ping() => _get('/me').then((_) {}).catchError((e) {
    if (e is ApiException && e.statusCode == 401) return;
    throw e;
  });

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> authLogin(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> authSendMagicLink(String email) =>
      _post('/auth/magic-link/send', {'email': email});

  Future<Map<String, dynamic>> authVerifyMagicLink(String token) =>
      _post('/auth/magic-link/verify', {'token': token});

  Future<Map<String, dynamic>> authRefresh({String? refreshToken}) =>
      _post('/auth/refresh', {
        if (refreshToken != null) 'refresh_token': refreshToken,
      });

  // ── Me / Account ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMe()                            => _get('/me');
  Future<Map<String, dynamic>> updateAccount(Map<String, dynamic> d) => _put('/me/account', d);

  // ── Home / Dashboard ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard()   => _get('/dashboard');
  Future<Map<String, dynamic>> getHeroBanners() => _get('/hero-banners');

  // ── Menu ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMenuVenues()            => _get('/menu');
  Future<Map<String, dynamic>> getMenuByVenue(String slug) => _get('/menu/$slug');

  // ── Events ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getEvents({int limit = 20})  => _get('/events?limit=$limit');
  Future<Map<String, dynamic>> getEventDetail(String id)     => _get('/events/$id');

  // ── Map / Venues ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getVenues() => _get('/venues');

  // ── Store ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStoreProducts()    => _get('/store/products');
  Future<Map<String, dynamic>> getCart()             => _get('/cart');
  Future<Map<String, dynamic>> cartAdd(Map<String, dynamic> item) => _post('/cart/add', item);
  Future<Map<String, dynamic>> cartUpdate(String id, int qty)     => _post('/cart/update', {'item_id': id, 'qty': qty});
  Future<Map<String, dynamic>> cartRemove(String id)              => _post('/cart/remove', {'item_id': id});
  Future<Map<String, dynamic>> cartClear()                        => _post('/cart/clear', {});
  Future<Map<String, dynamic>> cartCheckout({bool pickup = true, String pickupNotes = ''}) =>
      _post('/cart/checkout', {'pickup': pickup, 'pickup_notes': pickupNotes});
  Future<Map<String, dynamic>> getOrders() => _get('/orders');

  // ── Loyalty / Nova Keys ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNovaKeys()        => _get('/nova-keys');
  Future<Map<String, dynamic>> getLoyaltyAccount()  => _get('/loyalty/account');

  // ── Wonder (Nova-only — guarded by config.enableWonder) ──────────────────

  Future<Map<String, dynamic>> getAttunement()       => _get('/attunement');
  Future<Map<String, dynamic>> getJournal({int? memberId}) {
    final path = memberId != null ? '/journal?member_id=$memberId' : '/journal';
    return _get(path);
  }

  // ── HTTP plumbing ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path) =>
      _safe(() => http.get(Uri.parse('$apiBase$path'), headers: _headers)
          .timeout(const Duration(seconds: 15)));

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) =>
      _safe(() => http.post(Uri.parse('$apiBase$path'),
          headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15)));

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) =>
      _safe(() => http.put(Uri.parse('$apiBase$path'),
          headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15)));

  final _storage   = const FlutterSecureStorage();
  bool _refreshing = false;

  Future<Map<String, dynamic>> _safe(Future<http.Response> Function() call) async {
    try {
      final res = await call();
      if (res.statusCode == 401 && !_refreshing) {
        _refreshing = true;
        try {
          final refresh = await _storage.read(key: 'nv_refresh_token');
          if (refresh != null) {
            final rr = await _post('/auth/refresh', {'refresh_token': refresh});
            final newToken = rr['access_token'] as String?;
            if (newToken != null) {
              setToken(newToken);
              await _storage.write(key: 'nv_access_token', value: newToken);
              return _handle(await call());
            }
          }
        } catch (_) {
        } finally {
          _refreshing = false;
        }
      }
      return _handle(res);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException('Cannot reach server.\n(${e.message})', isRetryable: true);
    } on TimeoutException {
      throw const ApiException('Request timed out.', isRetryable: true);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic>? body;
    try { body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>; } catch (_) {}

    if (res.statusCode == 502 || res.statusCode == 503 || res.statusCode == 504) {
      throw ApiException('Server is starting up — hang tight.',
          statusCode: 503, isRetryable: true);
    }
    if (body == null) {
      throw ApiException('Unexpected response (${res.statusCode}).', statusCode: res.statusCode);
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    final msg = body['error'] ?? body['message'] ?? 'Request failed (${res.statusCode}).';
    throw ApiException(msg.toString(), statusCode: res.statusCode);
  }
}
