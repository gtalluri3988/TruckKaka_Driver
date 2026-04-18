class StorageKeys {
  // Access token (short-lived JWT). Kept in SharedPreferences since it
  // only lives 20 min and the background isolate needs fast sync access.
  static const String token = 'token';
  static const String accessTokenExpiresAt = 'access_token_expires_at';
  static const String tokenModel = 'jwt_data';

  // Refresh token lives in flutter_secure_storage (Keystore/Keychain).
  // Key is used with the secure storage backend, not SharedPreferences.
  static const String refreshToken = 'refresh_token';
  static const String refreshTokenExpiresAt = 'refresh_token_expires_at';

  // Stable device ID generated once on first launch.
  static const String deviceId = 'device_id';

  static const String login = 'login_data';
  static const String getUserByMobile = 'user_by_mobile';
  static const String menuList = 'menu_list';
  static const String language = 'language';
  static const String languageSet = 'language_set';
  static const String loginSuccess = 'login_success';
  static const String alreadyLogin = 'already_login';

  // ── Tracking ──────────────────────────────────────────────────────────
  static const String trackingTripId = 'tracking_trip_id';
  static const String trackingDriverId = 'tracking_driver_id';
  static const String trackingEnabled = 'tracking_enabled';
  static const String trackingConfig = 'tracking_config';
}
