import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';
import '../api/api_url.dart';
import '../model/get_user_by_mobile_model.dart';
import '../utils/local_storage/stored_data.dart';

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

  /// Step 2: Verify OTP and receive JWT.
  Future<http.Response> verifyOtp(String mobile, String otp) {
    return ApiService.ioPost(
      url: ApiUrl.verifyOtp,
      data: {'mobile': mobile, 'otp': otp},
    );
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
