import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_service.dart';
import '../../api/api_url.dart';
import '../../routes/app_routes.dart';
import '../../utils/local_storage/stored_data.dart';
import '../../utils/local_storage/stored_keys.dart';

class LanguageController extends GetxController {
  RxString selectedLang = 'en'.obs;
  RxBool isLoading = false.obs;

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'locale': 'en_US'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी', 'locale': 'hi_IN'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు', 'locale': 'te_IN'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்', 'locale': 'ta_IN'},
  ];

  void selectLanguage(String code) {
    selectedLang.value = code;
  }

  Future<void> confirmLanguage() async {
    isLoading.value = true;
    try {
      // Save locally
      await StoredData.setLanguage(language: selectedLang.value);

      // Apply locale
      final localeMap = {
        'en': const Locale('en', 'US'),
        'hi': const Locale('hi', 'IN'),
        'te': const Locale('te', 'IN'),
        'ta': const Locale('ta', 'IN'),
      };
      Get.updateLocale(localeMap[selectedLang.value] ?? const Locale('en', 'US'));

      // Persist to server
      final tokenModel = await StoredData.getTokenModel();
      if (tokenModel?.userId != null) {
        await ApiService.post(
          url: ApiUrl.updateLanguage,
          data: {
            'id': int.tryParse(tokenModel!.userId!) ?? 0,
            'userLanguage': selectedLang.value,
          },
        );
      }

      Get.offAllNamed(AppRoute.dashboard);
    } catch (e) {
      Get.offAllNamed(AppRoute.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final lang = await StoredData.getLanguage();
    if (lang != null) selectedLang.value = lang;
  }
}
