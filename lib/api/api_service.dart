import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'api_url.dart';
import '../utils/local_storage/stored_data.dart';

class ApiService {
  static final dio.Dio _dio = dio.Dio();
  static late IOClient _ioClient;

  static void init() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StoredData.getToken();
          final isAuthenticated = await StoredData.isAuthenticated();

          if (isAuthenticated && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Use print() — log() from dart:developer is unreliable in background
          // isolates (where the tracking service runs).
          final authHeader = options.headers['Authorization'];
          final authPreview = authHeader is String && authHeader.length > 20
              ? '${authHeader.substring(0, 20)}…(${authHeader.length}ch)'
              : (authHeader?.toString() ?? 'MISSING');
          // ignore: avoid_print
          print('REQUEST → ${options.method} ${options.uri} '
              'auth=$authPreview isAuth=$isAuthenticated');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // ignore: avoid_print
          print('RESPONSE ← ${response.statusCode} '
              '${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          // ignore: avoid_print
          print('ERROR ← ${error.response?.statusCode} '
              '${error.requestOptions.uri} '
              'body=${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    final httpClient =
        HttpClient()..badCertificateCallback = (cert, host, port) => true;
    _ioClient = IOClient(httpClient);
  }

  // ── HTTP fallback (no auth header) ──────────────────────────────────────

  static Future<http.Response> ioPost({
    required String url,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}$url')
        .replace(queryParameters: queryParameters);
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
    final uri = Uri.parse('${ApiUrl.baseUrl}$url')
        .replace(queryParameters: queryParameters);
    return _ioClient.get(uri, headers: {'Content-Type': 'application/json'});
  }

  // ── Dio (with JWT interceptor) ───────────────────────────────────────────

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
      // Surface the real failure so callers can see it in logcat.
      // The response is still an empty shell so non-exception callers keep working.
      // ignore: avoid_print
      print('ApiService.post FAILED url=${ApiUrl.baseUrl}$url '
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
    } on dio.DioException {
      return dio.Response(requestOptions: dio.RequestOptions());
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
      // ignore: avoid_print
      print('ApiService.get FAILED url=${ApiUrl.baseUrl}$url '
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
}
