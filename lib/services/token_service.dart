import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../api/api_url.dart';
import 'device_id_service.dart';
import 'secure_token_store.dart';

/// Coordinates access + refresh token lifecycle across the app.
///
/// Critical guarantees:
///   1. **Single in-flight refresh.** If 10 concurrent requests all hit 401,
///      only ONE /Auth/RefreshToken call fires — all callers await the
///      same Future. Without this, rotation + concurrent refresh =
///      multiple rotations = self-inflicted "reuse detected" logout.
///   2. **Cross-isolate safety.** The background tracking isolate has its
///      own TokenService instance. After a refresh, the new tokens are
///      persisted to shared storage (SharedPreferences + secure storage),
///      so the other isolate sees them on its next read.
///   3. **No Dio dependency.** TokenService uses the raw `http` client so
///      a refresh call can NEVER trigger its own interceptor's 401 handler.
///
/// Usage flow:
///   - On every outbound request, call [getValidAccessToken]. Returns a
///     token that's fresh for the next 60s or refreshes silently.
///   - On a 401 response, call [refresh] and retry the request once.
///   - On logout, call [logout] which revokes server-side + clears local.
class TokenService {
  TokenService._();
  static final TokenService instance = TokenService._();

  Future<String>? _refreshing;
  final _onLoggedOut = StreamController<void>.broadcast();

  /// Fires when the user must be sent back to the login screen
  /// (refresh token expired, revoked, reused, or user explicitly logged out).
  Stream<void> get onLoggedOut => _onLoggedOut.stream;

  /// Returns a non-expired access token or null if the user must re-login.
  /// Preemptively refreshes if the current token expires within 60s.
  Future<String?> getValidAccessToken() async {
    final current = await SecureTokenStore.getAccessToken();
    if (current == null || current.isEmpty) {
      // Never logged in or storage wiped — fall through to refresh attempt.
      return _tryRefreshOrNull();
    }

    if (await SecureTokenStore.isAccessTokenExpiringSoon()) {
      return _tryRefreshOrNull();
    }

    return current;
  }

  Future<String?> _tryRefreshOrNull() async {
    try {
      return await refresh();
    } catch (_) {
      return null;
    }
  }

  /// Exchange the stored refresh token for a new token pair.
  /// Concurrent callers share the same in-flight Future.
  /// Throws if the refresh token is missing/invalid — caller should
  /// treat that as "logged out".
  Future<String> refresh() {
    // If a refresh is already underway, join it instead of firing a second.
    final inflight = _refreshing;
    if (inflight != null) return inflight;

    final op = _doRefresh().whenComplete(() => _refreshing = null);
    _refreshing = op;
    return op;
  }

  Future<String> _doRefresh() async {
    final refreshToken = await SecureTokenStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleLoggedOut();
      throw _RefreshFailure('No refresh token stored');
    }

    final deviceId = await DeviceIdService.getDeviceId();

    // Bypass Dio entirely: the Dio interceptor retries on 401, which would
    // call refresh() recursively. Using a bare http client avoids that.
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );

    http.Response res;
    try {
      res = await client
          .post(
            Uri.parse('${ApiUrl.baseUrl}${ApiUrl.refreshToken}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'refreshToken': refreshToken,
              'deviceId': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      // Network failure — don't wipe tokens (user could be offline).
      throw _RefreshFailure('Network: $e');
    } finally {
      client.close();
    }

    if (res.statusCode == 401 || res.statusCode == 403) {
      // Refresh token was rejected by the server. Full logout.
      await _handleLoggedOut();
      throw _RefreshFailure('Refresh rejected: ${res.statusCode}');
    }

    if (res.statusCode != 200) {
      throw _RefreshFailure('Refresh failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final newAccess = data['accessToken'] as String?;
    final newRefresh = data['refreshToken'] as String?;
    final expiresIn = (data['accessTokenExpiresIn'] as num?)?.toInt() ?? 1200;
    final refreshExpiresAtRaw = data['refreshTokenExpiresAt'] as String?;
    final refreshExpiresAt = refreshExpiresAtRaw != null
        ? DateTime.tryParse(refreshExpiresAtRaw) ??
              DateTime.now().add(const Duration(days: 90))
        : DateTime.now().add(const Duration(days: 90));

    if (newAccess == null || newRefresh == null) {
      throw _RefreshFailure('Malformed refresh response');
    }

    await SecureTokenStore.saveAccessToken(newAccess, expiresIn);
    await SecureTokenStore.saveRefreshToken(newRefresh, refreshExpiresAt);

    return newAccess;
  }

  Future<void> _handleLoggedOut() async {
    await SecureTokenStore.clear();
    _onLoggedOut.add(null);
  }

  /// Explicit user-initiated logout. Best-effort server revoke + local wipe.
  Future<void> logout() async {
    final refreshToken = await SecureTokenStore.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      // Fire and forget — if the server is unreachable we still clear
      // local tokens so the user is logged out on this device.
      final client = IOClient(
        HttpClient()..badCertificateCallback = (_, __, ___) => true,
      );
      try {
        await client
            .post(
              Uri.parse('${ApiUrl.baseUrl}${ApiUrl.logout}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refreshToken': refreshToken}),
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // intentionally ignored
      } finally {
        client.close();
      }
    }

    await _handleLoggedOut();
  }
}

class _RefreshFailure implements Exception {
  _RefreshFailure(this.message);
  final String message;
  @override
  String toString() => 'RefreshFailure: $message';
}
