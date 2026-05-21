import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/api_models.dart';

/// Dio wrapper that injects the bearer token, single-flights a refresh on 401,
/// and surfaces typed [ApiError] for non-success responses.
class ApiClient {
  ApiClient(this.baseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Accept': 'application/json'},
          // Do not throw on 4xx/5xx — we want to map them to ApiError ourselves.
          validateStatus: (_) => true,
        )) {
    _dio.interceptors.add(_AuthInterceptor(this));
  }

  static const _accessKey = 'vf_access_token';
  static const _refreshKey = 'vf_refresh_token';
  static const _fridgeKey = 'vf_active_fridge_id';

  final String baseUrl;
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> storeTokens(TokenPair pair) async {
    await _storage.write(key: _accessKey, value: pair.accessToken);
    await _storage.write(key: _refreshKey, value: pair.refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _fridgeKey);
  }

  Future<int?> getActiveFridgeId() async {
    final raw = await _storage.read(key: _fridgeKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> setActiveFridgeId(int? id) async {
    if (id == null) {
      await _storage.delete(key: _fridgeKey);
    } else {
      await _storage.write(key: _fridgeKey, value: id.toString());
    }
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
      _send<T>('GET', path, query: query, skipAuth: skipAuth);

  Future<T> post<T>(String path, {Object? body, bool skipAuth = false}) =>
      _send<T>('POST', path, body: body, skipAuth: skipAuth);

  Future<T> patch<T>(String path, {Object? body}) =>
      _send<T>('PATCH', path, body: body);

  Future<T> delete<T>(String path, {Object? body}) =>
      _send<T>('DELETE', path, body: body);

  Future<T> _send<T>(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) async {
    final fridgeId = await getActiveFridgeId();
    final response = await _dio.request(
      path,
      data: body,
      queryParameters: query,
      options: Options(
        method: method,
        extra: {'skipAuth': skipAuth},
        headers: {
          if (fridgeId != null) 'X-Fridge-Id': fridgeId.toString(),
        },
      ),
    );

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw _toApiError(response);
    }

    return (response.statusCode == 204 ? null : response.data) as T;
  }

  ApiError _toApiError(Response response) {
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final code = (data['code'] ?? '') as String? ?? '';
      final error = (data['error'] ?? data['title'] ?? 'Request failed') as String? ?? 'Request failed';
      Map<String, List<String>>? validationErrors;
      if (data['errors'] is Map) {
        validationErrors = (data['errors'] as Map).map(
          (k, v) => MapEntry(k as String, (v as List).cast<String>()),
        );
      }
      return ApiError(status, code, error, validationErrors: validationErrors);
    }

    return ApiError(status, '', 'Request failed with $status');
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);

  final ApiClient _client;
  static Future<TokenPair?>? _inflightRefresh;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = await _client.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Single-flight refresh on 401 (unless this request already opted out of auth).
    if (response.statusCode == 401 && response.requestOptions.extra['skipAuth'] != true) {
      final refresh = await _client.getRefreshToken();
      if (refresh != null) {
        _inflightRefresh ??= _refresh(refresh);
        final pair = await _inflightRefresh!;
        _inflightRefresh = null;
        if (pair != null) {
          // Retry the original request with the fresh token.
          final retry = await _client._dio.fetch(
            response.requestOptions.copyWith(
              headers: {
                ...response.requestOptions.headers,
                'Authorization': 'Bearer ${pair.accessToken}',
              },
            ),
          );
          return handler.resolve(retry);
        }
        // Refresh failed — wipe tokens so the UI bounces back to /signin.
        await _client.clearTokens();
      }
    }
    handler.next(response);
  }

  Future<TokenPair?> _refresh(String refreshToken) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: _client.baseUrl));
      final res = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      if (res.statusCode != 200) return null;
      final pair = TokenPair.fromJson(res.data as Map<String, dynamic>);
      await _client.storeTokens(pair);
      return pair;
    } catch (_) {
      return null;
    }
  }
}
