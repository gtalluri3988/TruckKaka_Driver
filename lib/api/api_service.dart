import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../services/secure_token_store.dart';
import '../services/token_service.dart';
import '../utils/local_storage/stored_data.dart';
import 'api_url.dart';

class ApiService {
  static final dio.Dio _dio = dio.Dio();
  static late IOClient _ioClient;

  static void init() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    final httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    _ioClient = IOClient(httpClient);
  }

  // ── Dio interceptor callbacks ────────────────────────────────────────────

  static Future<void> _onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    // Never attach a token to the refresh-token endpoint itself — that call
    // uses its own refresh-token body; adding a stale Bearer would trigger a
    // 401 loop.
    if (options.path.contains(ApiUrl.refreshToken)) {
      _log('REQUEST → ${options.method} ${options.uri} auth=NONE (refresh)');
      handler.next(options);
      return;
    }

    // Ask TokenService for a token that's fresh for the next 60s. This
    // triggers a preemptive refresh if we're near expiry — better than
    // waiting for a 401 round-trip.
    final token = await TokenService.instance.getValidAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Fall back to legacy storage so pre-refresh-upgrade sessions keep
      // working until their access token expires naturally.
      final legacy = await StoredData.getToken();
      if (legacy != null && legacy.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $legacy';
      }
    }

    final authHeader = options.headers['Authorization'];
    final authPreview = authHeader is String && authHeader.length > 20
        ? '${authHeader.substring(0, 20)}…(${authHeader.length}ch)'
        : (authHeader?.toString() ?? 'MISSING');
    _log('REQUEST → ${options.method} ${options.uri} auth=$authPreview');

    handler.next(options);
  }

  static void _onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) {
    _log('RESPONSE ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  /// On 401: refresh once and retry the original request. Multiple concurrent
  /// requests that all hit 401 share the same refresh Future via TokenService.
  static Future<void> _onError(
    dio.DioException error,
    dio.ErrorInterceptorHandler handler,
  ) async {
    final status = error.response?.statusCode;
    final path = error.requestOptions.path;

    _log('ERROR ← $status $path body=${error.response?.data}');

    // Only intercept 401s AND make sure:
    //   • we're not already retrying (flagged via extra)
    //   • the 401 didn't come from the refresh endpoint itself
    //   • the request can be replayed (has a body captured by Dio)
    final alreadyRetried = error.requestOptions.extra['__retried_401'] == true;
    final isRefreshCall = path.contains(ApiUrl.refreshToken);

    if (status != 401 || alreadyRetried || isRefreshCall) {
      handler.next(error);
      return;
    }

    try {
      final newToken = await TokenService.instance.refresh();

      // Replay the original request with the new token and a flag so a
      // second 401 won't loop us back into refresh again.
      final retryOptions = error.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      retryOptions.extra['__retried_401'] = true;

      final retryResponse = await _dio.fetch(retryOptions);
      _log('RETRY ✓ ${retryResponse.statusCode} $path');
      handler.resolve(retryResponse);
    } catch (e) {
      // Refresh failed (token expired/revoked/reused, or network). User is
      // effectively logged out — TokenService has emitted the event and
      // cleared storage. Propagate the original 401 so the UI can react.
      _log('RETRY ✗ $path — $e');
      handler.next(error);
    }
  }

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  // ── HTTP fallback (no auth header) ──────────────────────────────────────

  static Future<http.Response> ioPost({
    required String url,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}$url',
    ).replace(queryParameters: queryParameters);
    return _ioClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> ioGet({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}$url',
    ).replace(queryParameters: queryParameters);
    return _ioClient.get(uri, headers: {'Content-Type': 'application/json'});
  }

  // ── Dio (with JWT + refresh interceptor) ─────────────────────────────────

  static Future<dio.Response> post({
    required String url,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        '${ApiUrl.baseUrl}$url',
        data: jsonEncode(data),
        queryParameters: queryParameters,
        options: dio.Options(headers: {'Content-Type': 'application/json'}),
      );
    } on dio.DioException catch (e) {
      _log('ApiService.post FAILED url=${ApiUrl.baseUrl}$url '
          'type=${e.type} message=${e.message} '
          'responseStatus=${e.response?.statusCode} '
          'responseBody=${e.response?.data}');
      return e.response ??
          dio.Response(requestOptions: dio.RequestOptions(path: url));
    }
  }

  static Future<dio.Response> postWithFormData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        '${ApiUrl.baseUrl}$url',
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on dio.DioException catch (e) {
      _log('ApiService.postWithFormData FAILED url=${ApiUrl.baseUrl}$url '
          'type=${e.type} status=${e.response?.statusCode}');
      return e.response ??
          dio.Response(requestOptions: dio.RequestOptions(path: url));
    }
  }

  static Future<dio.Response> get({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        '${ApiUrl.baseUrl}$url',
        queryParameters: queryParameters,
      );
    } on dio.DioException catch (e) {
      _log('ApiService.get FAILED url=${ApiUrl.baseUrl}$url '
          'type=${e.type} message=${e.message} '
          'responseStatus=${e.response?.statusCode} '
          'responseBody=${e.response?.data}');
      return e.response ??
          dio.Response(requestOptions: dio.RequestOptions(path: url));
    }
  }

  static Future<bool> isNetworkAvailable() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  // Kept for any call site that wants direct access (migration helper).
  static Future<String?> currentAccessToken() => SecureTokenStore.getAccessToken();
}
