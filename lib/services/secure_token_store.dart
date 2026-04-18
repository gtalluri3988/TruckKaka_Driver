import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/local_storage/stored_keys.dart';

/// Split storage for the token pair:
///
///   • Access token (short-lived) → SharedPreferences. Fast sync access
///     across isolates (needed by the background tracking service).
///   • Refresh token (long-lived)  → flutter_secure_storage. Backed by
///     Android Keystore / iOS Keychain so it's encrypted at rest and
///     NOT extractable via `adb backup` or rooted filesystem access.
///
/// Expiry timestamps are stored next to each token so the client can
/// schedule preemptive refreshes without decoding the JWT every time.
class SecureTokenStore {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Access token ─────────────────────────────────────────────────────

  static Future<void> saveAccessToken(String accessToken, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, accessToken);
    final expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await prefs.setString(
      StorageKeys.accessTokenExpiresAt,
      expiresAt.toIso8601String(),
    );
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  static Future<DateTime?> getAccessTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.accessTokenExpiresAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// True if the access token is null/empty or within the `skew` seconds
  /// of expiry (so we refresh preemptively rather than waiting for a 401).
  static Future<bool> isAccessTokenExpiringSoon({int skewSeconds = 60}) async {
    final expiresAt = await getAccessTokenExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(
      expiresAt.subtract(Duration(seconds: skewSeconds)),
    );
  }

  // ── Refresh token (secure) ───────────────────────────────────────────

  static Future<void> saveRefreshToken(
    String refreshToken,
    DateTime expiresAt,
  ) async {
    await _secure.write(key: StorageKeys.refreshToken, value: refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.refreshTokenExpiresAt,
      expiresAt.toIso8601String(),
    );
  }

  static Future<String?> getRefreshToken() async {
    return _secure.read(key: StorageKeys.refreshToken);
  }

  static Future<DateTime?> getRefreshTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.refreshTokenExpiresAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  // ── Clear ────────────────────────────────────────────────────────────

  /// Wipe every trace of the current session. Called on logout,
  /// refresh failure, or token reuse detection from the server.
  static Future<void> clear() async {
    await _secure.delete(key: StorageKeys.refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.accessTokenExpiresAt);
    await prefs.remove(StorageKeys.refreshTokenExpiresAt);
    await prefs.remove(StorageKeys.tokenModel);
  }
}
