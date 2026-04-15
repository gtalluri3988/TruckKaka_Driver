import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/login_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/dialogue_service/dialogues.dart';
import '../../utils/local_storage/stored_data.dart';
import '../../utils/local_storage/stored_keys.dart';

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxString mobile = ''.obs;
  RxString otpError = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isNotAssigned = false.obs;
  RxInt secondsRemaining = 47.obs;
  RxBool canResend = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    mobile.value = args?['mobile'] ?? '';
    _startTimer();
  }

  @override
  void onClose() {
    otpController.dispose();
    otpFocusNode.dispose();
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    secondsRemaining.value = 47;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        t.cancel();
        canResend.value = true;
      }
    });
  }

  void resendOtp() {
    if (!canResend.value) return;
    _startTimer();
    Dialogues.infoToast('OTP resent to ${mobile.value}');
    // TODO: call resend API when backend exposes it
  }

  /// Fire-and-forget: save the current FCM token to the server.
  /// Called after successful OTP verification so the UserFCMToken table
  /// always holds the latest token (it can rotate between app installs).
  Future<void> _saveFcmTokenSilently() async {
    try {
      final tokenModel = await StoredData.getTokenModel();
      final userId = int.tryParse(tokenModel?.userId ?? '');
      if (userId == null) return;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      await AuthService().saveFcmToken(userId, fcmToken);
      log('FCM token refreshed for userId=$userId');
    } catch (e) {
      log('_saveFcmTokenSilently error: $e');
    }
  }

  Future<void> verifyOtp() async {
    if (mobile.value.isEmpty || otpController.text.length < 4) {
      Dialogues.warningToast('Please enter the OTP');
      return;
    }

    isLoading.value = true;
    otpError.value = '';
    isNotAssigned.value = false;

    try {
      final res = await AuthService().verifyOtp(
        mobile.value,
        otpController.text.trim(),
      );

      if (res.statusCode == 200) {
        log('OTP response: ${res.body}');
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
        final loginData = LoginModel.fromJson(
            jsonMap['data'] as Map<String, dynamic>);

        // ── Save session data ─────────────────────────────────────────────
        await StoredData.saveToken(loginData.token ?? '');
        await StoredData.saveTokenAsModel(loginData.token ?? '');
        await StoredData.saveLoginModel(loginData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.login, jsonEncode(loginData.toJson()));

        // ── Refresh FCM token on server ───────────────────────────────────
        // Ensures the token stored in UserFCMToken table is always current,
        // even if the token rotated since the last Register/RegisterUser call.
        _saveFcmTokenSilently();

        // Fetch user profile (language/role flags)
        final userByMobile = await AuthService().getUserByMobile(mobile.value);

        if (userByMobile != null) {
          // 2. KYC check — driver must have license uploaded
          // (licenseNo is checked on trip acceptance by API, not here)

          await prefs.setBool(
            StorageKeys.languageSet,
            userByMobile.isLanguageSelected ?? false,
          );

          // Route decision
          if (!(userByMobile.isLanguageSelected ?? false)) {
            Get.offAllNamed(AppRoute.language);
          } else {
            Get.offAllNamed(AppRoute.dashboard);
          }
        } else {
          // No profile fetched — default to language selection
          Get.offAllNamed(AppRoute.language);
        }
      } else if (res.statusCode == 403) {
        // Driver is not assigned to any owner — hard block
        isNotAssigned.value = true;
      } else {
        otpError.value = 'Invalid OTP';
        formKey.currentState?.validate();
        Dialogues.warningToast('Invalid OTP. Please try again.');
      }
    } catch (e) {
      log('verifyOtp error: $e');
      Dialogues.warningToast('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
