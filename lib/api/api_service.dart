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

          log('REQUEST → ${options.uri}');
          log('Headers: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          log('RESPONSE ← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          log('ERROR ← $error');
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
    } on dio.DioException {
      return dio.Response(requestOptions: dio.RequestOptions());
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
    } on dio.DioException {
      return dio.Response(requestOptions: dio.RequestOptions());
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
