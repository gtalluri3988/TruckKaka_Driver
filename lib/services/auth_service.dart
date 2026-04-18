import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';
import '../api/api_url.dart';
import '../model/get_user_by_mobile_model.dart';
import '../utils/local_storage/stored_data.dart';
import 'device_id_service.dart';
import 'secure_token_store.dart';
import 'token_service.dart';

class AuthService {
  /// Pre-login check: verify mobile is in User table AND has Driver record with OwnerId set.
  /// Returns true if allowed, false if driver was never added by an owner.
  Future<bool> checkDriverAccess(String mobile) async {
    try {
      final res = await ApiService.ioGet(
        url: ApiUrl.checkDriverAccess,
        queryParameters: {'mobile': mobile},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Step 1: Register phone (sends OTP).
  Future<http.Response> register(String phone, String fcmToken) {
    return ApiService.ioPost(
      url: ApiUrl.register,
      data: {'mobile': phone, 'fcmToken': fcmToken},
    );
  }

  /// Step 2: Verify OTP and receive token pair.
  /// Passes deviceId + deviceName so the backend can track this session
  /// separately from the user's other devices.
  Future<http.Response> verifyOtp(String mobile, String otp) async {
    final deviceId = await DeviceIdService.getDeviceId();
    final deviceName = await DeviceIdService.getDeviceName();

    return ApiService.ioPost(
      url: ApiUrl.verifyOtp,
      data: {
        'mobile': mobile,
        'otp': otp,
        'deviceId': deviceId,
        'deviceName': deviceName,
      },
    );
  }

  /// Persist both tokens from a login response. Call this after verifyOtp
  /// (and any other endpoint that returns AuthenticationResponseDTO) so
  /// the refresh interceptor has what it needs.
  Future<void> persistTokensFromResponse(Map<String, dynamic> body) async {
    // The response shape is AuthenticationResponseDTO wrapped in
    // { success, message, data: {...} } for VerifyOTP. Unwrap defensively.
    final data = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    final access = (data['accessToken'] as String?) ??
        (data['token'] as String?); // legacy fallback
    final refresh = data['refreshToken'] as String?;
    final expiresIn = (data['accessTokenExpiresIn'] as num?)?.toInt() ?? 1200;
    final refreshExpRaw = data['refreshTokenExpiresAt'] as String?;
    final refreshExp = refreshExpRaw != null
        ? DateTime.tryParse(refreshExpRaw) ??
              DateTime.now().add(const Duration(days: 90))
        : DateTime.now().add(const Duration(days: 90));

    if (access != null && access.isNotEmpty) {
      await SecureTokenStore.saveAccessToken(access, expiresIn);
      // Keep legacy StoredData in sync so older call sites that read
      // StoredData.getToken() directly keep working during migration.
      await StoredData.saveToken(access);
      await StoredData.saveTokenAsModel(access);
    }
    if (refresh != null && refresh.isNotEmpty) {
      await SecureTokenStore.saveRefreshToken(refresh, refreshExp);
    }
  }

  /// Logout: best-effort server-side revoke then full local wipe.
  /// Safe to call even if already logged out.
  Future<void> logout() async {
    await TokenService.instance.logout();
    await StoredData.clearAll();
  }

  /// Fetch user profile by mobile number (flags: language, role, KYC).
  Future<GetUserByMobileModel?> getUserByMobile(String mobile) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.getUserByMobile,
        queryParameters: {'mobile': mobile},
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data is String ? jsonDecode(res.data) : res.data;
        final model = GetUserByMobileModel.fromJson(
          data['result'] as Map<String, dynamic>,
        );
        await StoredData.saveUserByMobile(model);
        return model;
      }
    } catch (e) {
      log('getUserByMobile error: $e');
    }
    return null;
  }

  /// Save FCM token to server after login.
  Future<void> saveFcmToken(int userId, String fcmToken) async {
    try {
      await ApiService.post(
        url: ApiUrl.saveFcm,
        data: {'userId': userId, 'fcmToken': fcmToken},
      );
    } catch (e) {
      log('saveFcmToken error: $e');
    }
  }
}
