import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../model/location_model.dart';
import '../utils/local_storage/stored_keys.dart';
import 'location_queue_service.dart';
import 'location_service.dart';
import 'location_sync_service.dart';

// ──────────────────────────────────────────────────────────────────────────
//  Top-level isolate entry point.
//  flutter_background_service resolves `onStart` by NAME via the native side
//  and requires a top-level (or static) function annotated with
//  @pragma('vm:entry-point'). Static class methods are unreliable across
//  plugin versions — top-level is the safe default.
// ──────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> backgroundTrackingOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // Use print() — log() from dart:developer can be dropped in background isolates.
  // ignore: avoid_print
  print('BackgroundTracking isolate: _onStart entered');

  // CRITICAL: each Dart isolate has its own static state. Dio and its
  // auth interceptor were registered in the MAIN isolate — the background
  // isolate starts with a bare Dio instance, which means no
  // Authorization header is attached and every request gets 401.
  // Re-initialize here so the isolate's Dio has the JWT interceptor too.
  ApiService.init();
  // ignore: avoid_print
  print('BackgroundTracking isolate: ApiService.init() called');

  int? tripId;
  int? driverId;
  StreamSubscription? locationSub;
  Timer? syncTimer;
  final locationService = LocationService();

  final prefs = await SharedPreferences.getInstance();
  tripId = prefs.getInt(StorageKeys.trackingTripId);
  driverId = prefs.getInt(StorageKeys.trackingDriverId);
  // ignore: avoid_print
  print('BackgroundTracking isolate: prefs read tripId=$tripId driverId=$driverId');

  try {
    final config = await LocationSyncService.fetchConfig();
    if (config != null) locationService.updateConfig(config);
  } catch (_) {}

  service.on('startTracking').listen((event) {
    tripId = event?['tripId'] as int?;
    driverId = event?['driverId'] as int?;
    // ignore: avoid_print
    print('BackgroundTracking isolate: received startTracking '
        'trip=$tripId driver=$driverId');
  });

  service.on('stopTracking').listen((_) async {
    // ignore: avoid_print
    print('BackgroundTracking isolate: received stopTracking');
    locationSub?.cancel();
    syncTimer?.cancel();
    await service.stopSelf();
  });

  service.on('stopService').listen((_) async {
    // ignore: avoid_print
    print('BackgroundTracking isolate: received stopService');
    locationSub?.cancel();
    syncTimer?.cancel();
    await service.stopSelf();
  });

  if (tripId == null || driverId == null) {
    await Future.delayed(const Duration(seconds: 2));
    tripId = prefs.getInt(StorageKeys.trackingTripId);
    driverId = prefs.getInt(StorageKeys.trackingDriverId);
  }

  if (tripId == null || driverId == null) {
    // ignore: avoid_print
    print('BackgroundTracking isolate: no tripId/driverId, stopping');
    await service.stopSelf();
    return;
  }

  final hasPermission = await locationService.hasPermission();
  // ignore: avoid_print
  print('BackgroundTracking isolate: hasPermission returned $hasPermission');
  if (!hasPermission) {
    // ignore: avoid_print
    print('BackgroundTracking isolate: permission NOT granted, stopping');
    await service.stopSelf();
    return;
  }

  final gpsEnabled = await locationService.isGpsEnabled();
  // ignore: avoid_print
  print('BackgroundTracking isolate: GPS hardware enabled=$gpsEnabled');

  // ignore: avoid_print
  print('BackgroundTracking isolate: subscribing to location stream for trip=$tripId');
  var firstSyncTriggered = false;
  locationSub = locationService.startTracking(tripId!).listen(
    (point) async {
      // ignore: avoid_print
      print('BackgroundTracking isolate: point emitted '
          'lat=${point.latitude} lng=${point.longitude} '
          'acc=${point.accuracy} gps=${point.isGpsEnabled}');
      await LocationQueueService.enqueue(point);

      // Flush the very first point immediately so the admin map shows
      // the driver without waiting 30s for the periodic timer.
      if (!firstSyncTriggered && tripId != null) {
        firstSyncTriggered = true;
        // ignore: avoid_print
        print('BackgroundTracking isolate: triggering immediate first sync');
        await LocationSyncService.syncPendingLocations(tripId!, batchSize: 50);
      }
    },
    onError: (e) {
      // ignore: avoid_print
      print('BackgroundTracking GPS stream error: $e');
    },
  );

  syncTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
    if (tripId == null) return;

    final updatedConfig = await LocationSyncService.syncPendingLocations(
      tripId!,
      batchSize: 50,
    );

    if (updatedConfig != null) {
      locationService.updateConfig(updatedConfig);
    }

    final pending = await LocationQueueService.pendingCount();
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'TruckKaka Driver',
        content: pending > 0
            ? 'Tracking active ($pending points queued)'
            : 'Tracking active',
      );
    }
  });
}

/// Orchestrates background GPS tracking using an Android foreground service.
/// Survives app minimization, recents clearing, and device sleep.
class BackgroundTrackingService {
  static const String _notificationChannelId = 'truckkaka_tracking';
  static const String _notificationChannelName = 'Trip Tracking';
  static const int _notificationId = 888;

  /// Initialize the background service (call once at app startup).
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Create a persistent notification channel for the foreground service
    const androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Shows when GPS tracking is active for a trip',
      importance: Importance.low,
    );

    final flnPlugin = FlutterLocalNotificationsPlugin();
    await flnPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundTrackingOnStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'TruckKaka Driver',
        initialNotificationContent: 'Trip tracking is active',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: backgroundTrackingOnStart,
      ),
    );
  }

  /// Start background tracking for a specific trip.
  /// Always force-restarts any existing service so the newly-installed
  /// APK's code is guaranteed to run (avoids zombie isolates from a
  /// previous install of the APK).
  static Future<void> startTracking(int tripId, int driverId) async {
    // Persist trip/driver IDs so the isolate can read them
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.trackingTripId, tripId);
    await prefs.setInt(StorageKeys.trackingDriverId, driverId);
    await prefs.setBool(StorageKeys.trackingEnabled, true);

    final service = FlutterBackgroundService();
    final wasRunning = await service.isRunning();

    // Kill any running (possibly zombie) isolate first so the fresh
    // service we start picks up the current APK's code.
    if (wasRunning) {
      log('BackgroundTracking: existing service detected — stopping it '
          'before starting fresh');
      service.invoke('stopService');
      // Give Android a moment to tear down the old service
      await Future.delayed(const Duration(milliseconds: 600));
    }

    await service.startService();

    // Send start command to the isolate
    service.invoke('startTracking', {
      'tripId': tripId,
      'driverId': driverId,
    });

    log('BackgroundTracking: started for trip=$tripId driver=$driverId');
  }

  /// Stop background tracking.
  static Future<void> stopTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.trackingEnabled, false);
    await prefs.remove(StorageKeys.trackingTripId);
    await prefs.remove(StorageKeys.trackingDriverId);

    final service = FlutterBackgroundService();
    service.invoke('stopTracking');

    log('BackgroundTracking: stopped');
  }

  /// Check if the background service is currently running.
  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  // Isolate entry point moved to top-level `backgroundTrackingOnStart`
  // (above the class) — required by flutter_background_service for
  // reliable name-based lookup.
}
