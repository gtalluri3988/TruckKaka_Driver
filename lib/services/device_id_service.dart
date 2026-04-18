import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/local_storage/stored_keys.dart';

/// Provides a stable per-install device identifier + human-readable label
/// sent to the backend on login and refresh. The backend stores these on
/// the RefreshToken row to enable per-device session management.
///
/// We cache the ID in SharedPreferences so it survives the first refresh
/// call even if device_info_plus is temporarily slow.
class DeviceIdService {
  static String? _cachedId;
  static String? _cachedName;

  static Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(StorageKeys.deviceId);
    if (existing != null && existing.isNotEmpty) {
      _cachedId = existing;
      return existing;
    }

    final info = DeviceInfoPlugin();
    String id = 'unknown';
    try {
      if (Platform.isAndroid) {
        // androidId is stable across app reinstalls on the same device.
        final android = await info.androidInfo;
        id = android.id;
      } else if (Platform.isIOS) {
        // identifierForVendor is reset if all apps from the vendor are
        // uninstalled, which matches our "one device = one session" intent.
        final ios = await info.iosInfo;
        id = ios.identifierForVendor ?? 'ios-unknown';
      }
    } catch (_) {
      // Fallback: random UUID-like string persisted locally. Worst case
      // we lose per-device tracking but auth still works.
      id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    await prefs.setString(StorageKeys.deviceId, id);
    _cachedId = id;
    return id;
  }

  static Future<String> getDeviceName() async {
    if (_cachedName != null) return _cachedName!;

    final info = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        _cachedName = '${a.manufacturer} ${a.model}'.trim();
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        _cachedName = '${i.name} (${i.model})';
      }
    } catch (_) {}

    return _cachedName ?? 'Unknown device';
  }
}
