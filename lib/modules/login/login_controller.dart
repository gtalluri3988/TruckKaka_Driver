import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';
import '../../api/api_url.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/dialogue_service/dialogues.dart';
import '../../utils/local_storage/stored_keys.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();
  final FocusNode mobileFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxString accessError = ''.obs;

  @override
  void onClose() {
    mobileController.dispose();
    mobileFocus.dispose();
    super.onClose();
  }

  Future<void> login() async {
    mobileFocus.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    accessError.value = '';

    try {
      final mobile = mobileController.text.trim();

      // Step 1: Check if driver exists and is assigned to an owner
      final isAllowed = await AuthService().checkDriverAccess(mobile);
      if (!isAllowed) {
        accessError.value =
            'You are not assigned to any owner. Contact admin.';
        return;
      }

      // Step 2: Send OTP
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final res = await ApiService.ioPost(
        url: ApiUrl.register,
        data: {'mobile': mobile, 'fcmToken': fcmToken ?? ''},
      );

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(StorageKeys.alreadyLogin, true);
        Get.toNamed(AppRoute.otp, arguments: {'mobile': mobile});
        mobileController.clear();
      } else {
        Dialogues.warningToast('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      log('login error: $e');
      Dialogues.warningToast('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
