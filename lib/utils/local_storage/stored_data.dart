import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/token_model.dart';
import '../../model/login_model.dart';
import '../../model/get_user_by_mobile_model.dart';
import 'stored_keys.dart';

class StoredData {
  // ── Token ────────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveTokenAsModel(String token) async {
    try {
      final decoded = JwtDecoder.decode(token);
      final model = TokenModel.fromJson(decoded);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          StorageKeys.tokenModel, jsonEncode(model.toJson()));
    } catch (e) {
      debugPrint('❌ saveTokenAsModel error: $e');
    }
  }

  static Future<TokenModel?> getTokenModel() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(StorageKeys.tokenModel);
    if (data == null) return null;
    try {
      return TokenModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // ── Login Model ───────────────────────────────────────────────────────────

  static Future<void> saveLoginModel(LoginModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.login, jsonEncode(model.toJson()));
  }

  static Future<LoginModel?> getSavedLoginModel() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(StorageKeys.login);
    if (data == null) return null;
    try {
      return LoginModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // ── User by Mobile ────────────────────────────────────────────────────────

  static Future<void> saveUserByMobile(GetUserByMobileModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        StorageKeys.getUserByMobile, jsonEncode(model.toJson()));
  }

  static Future<GetUserByMobileModel?> getSavedUserByMobile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(StorageKeys.getUserByMobile);
    if (data == null) return null;
    try {
      return GetUserByMobileModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // ── Language ──────────────────────────────────────────────────────────────

  static Future<void> setLanguage({required String language}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.language, language);
  }

  static Future<void> applyStoredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(StorageKeys.language);
    if (lang == null) return;
    Locale locale;
    switch (lang) {
      case 'hi':
        locale = const Locale('hi', 'IN');
        break;
      case 'te':
        locale = const Locale('te', 'IN');
        break;
      case 'ta':
        locale = const Locale('ta', 'IN');
        break;
      default:
        locale = const Locale('en', 'US');
    }
    Get.updateLocale(locale);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.language);
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.tokenModel);
    await prefs.remove(StorageKeys.login);
    await prefs.remove(StorageKeys.getUserByMobile);
    await prefs.remove(StorageKeys.menuList);
    await prefs.remove(StorageKeys.languageSet);
    await prefs.remove(StorageKeys.loginSuccess);
    await prefs.remove(StorageKeys.alreadyLogin);
    debugPrint('🧹 StoredData cleared on logout');
  }
}
