import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../firebase_options.dart';
import '../modules/home/home_controller.dart';
import '../routes/app_routes.dart';
import '../utils/local_storage/stored_data.dart';

/// Top-level FCM background handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint('🔔 Background FCM: ${message.messageId}');
}

class AppInit {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'truckkaka_driver_channel',
    'TruckKaka Driver Notifications',
    description: 'Trip assignments and updates for drivers.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // ── Firebase ────────────────────────────────────────────────────────────────
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Local notifications (Android channel + foreground display) ──────────────
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
      // Called when user taps a local notification shown while app was in foreground.
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ── Cold start (app was KILLED, user taps notification) ──────────────────────
    // Splash → auth check → /dashboard → HomeController.onReady → _checkActiveTrip
    // shows the accept/reject popup automatically. No extra handling needed here.
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      // Nothing to do — the existing splash auth-guard routes to dashboard,
      // and HomeController._checkActiveTrip() shows the trip popup on load.
      if (message != null) {
        debugPrint('🔔 Cold-start notification: type=${message.data['type']}');
      }
    });

    // ── Background (app minimised, user taps notification) ──────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped (background): type=${message.data['type']}');
      if (message.data['type'] == 'TRIP_ASSIGNED') {
        _openTripAssignment();
      }
    });

    // ── Foreground (app is open, FCM arrives) ───────────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      // Show heads-up local notification
      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          // Encode FCM data as payload so tap handler can navigate correctly.
          payload: jsonEncode(message.data),
        );
      }

      // If driver is already on the dashboard, refresh the active-trip check
      // so the accept/reject popup shows immediately without needing a tap.
      if (message.data['type'] == 'TRIP_ASSIGNED') {
        try {
          Get.find<HomeController>().refreshActiveTrip();
        } catch (_) {
          // HomeController not yet registered — notification will show instead.
        }
      }
    });
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  /// Called when user taps a LOCAL notification (foreground-delivered FCM message).
  static void _onLocalNotificationTap(NotificationResponse response) {
    try {
      final data =
          jsonDecode(response.payload ?? '{}') as Map<String, dynamic>;
      if (data['type'] == 'TRIP_ASSIGNED') {
        _openTripAssignment();
      }
    } catch (e) {
      debugPrint('_onLocalNotificationTap error: $e');
    }
  }

  /// Navigate to the dashboard and show the accept/reject trip popup.
  ///
  /// Works for both cases:
  /// - User is on a sub-screen → navigate back to dashboard, HomeController
  ///   is re-mounted and its `onReady` calls `_checkActiveTrip`.
  /// - HomeController already active → delayed `refreshActiveTrip` call
  ///   shows the popup even though `onReady` won't fire again.
  static void _openTripAssignment() async {
    if (!await StoredData.isAuthenticated()) return;

    Get.offAllNamed(AppRoute.dashboard);

    // Wait for the dashboard widget tree to mount and HomeController to register,
    // then trigger an explicit active-trip refresh in case onReady already ran.
    Future.delayed(const Duration(milliseconds: 400), () {
      try {
        Get.find<HomeController>().refreshActiveTrip();
      } catch (_) {}
    });
  }
}
