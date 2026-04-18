import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../model/location_model.dart';

/// Wraps the geolocator package with smart interval tracking,
/// accuracy filtering, distance filtering, and mock detection.
class LocationService {
  TrackingConfig _config = TrackingConfig();
  Position? _lastValidPosition;

  void updateConfig(TrackingConfig config) {
    _config = config;
  }

  // ── Permissions ───────────────────────────────────────────────────────

  /// Check and request location permissions. Returns true if granted.
  /// IMPORTANT: must be called from the main isolate (UI context) —
  /// Geolocator.requestPermission() requires an Activity and will throw
  /// from a background service isolate.
  Future<bool> requestPermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      log('LocationService: permissions permanently denied');
      return false;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Check-only variant — safe to call from a background isolate.
  /// Does NOT show the system dialog. Returns true only if the user
  /// has granted "Allow all the time" (LocationPermission.always).
  /// "While using the app" is insufficient: Android stops background
  /// GPS delivery to the foreground service as soon as the app leaves
  /// the screen, so points never arrive.
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always;
  }

  /// Check if GPS/location services are enabled on the device.
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // ── Single Position ───────────────────────────────────────────────────

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      log('LocationService getCurrentPosition error: $e');
      return null;
    }
  }

  // ── Continuous Tracking ───────────────────────────────────────────────

  /// Returns a stream of validated LocationPoints for a given tripId.
  /// Applies accuracy filtering, distance filtering, and smart intervals.
  Stream<LocationPoint> startTracking(int tripId) {
    final controller = StreamController<LocationPoint>();

    _startGpsStream(tripId, controller);

    return controller.stream;
  }

  Future<void> _startGpsStream(
    int tripId,
    StreamController<LocationPoint> controller,
  ) async {
    // Use a periodic timer with smart interval instead of geolocator's
    // built-in stream, which doesn't support dynamic interval changes.
    var intervalMs = _config.idleIntervalSeconds * 1000;

    while (!controller.isClosed) {
      try {
        final gpsEnabled = await isGpsEnabled();

        if (!gpsEnabled) {
          // Emit a GPS-disabled point so the queue records the event
          controller.add(
            LocationPoint(
              tripId: tripId,
              latitude: _lastValidPosition?.latitude ?? 0,
              longitude: _lastValidPosition?.longitude ?? 0,
              isGpsEnabled: false,
              isMockLocation: false,
              recordedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );
          await Future.delayed(Duration(milliseconds: intervalMs));
          continue;
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        // Accuracy filter
        if (position.accuracy > _config.accuracyThresholdMeters) {
          log('LocationService: point REJECTED by accuracy filter '
              '(acc=${position.accuracy}m > ${_config.accuracyThresholdMeters}m)');
          await Future.delayed(Duration(milliseconds: intervalMs));
          continue;
        }

        // Distance filter — stationary readings are still emitted as a
        // heartbeat so the admin map knows the driver is online and where
        // they're parked. We just use the longer idle interval so we
        // don't spam GPS polls / queue inserts.
        var isStationary = false;
        if (_lastValidPosition != null) {
          final distance = Geolocator.distanceBetween(
            _lastValidPosition!.latitude,
            _lastValidPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          if (distance < _config.distanceFilterMeters) {
            isStationary = true;
            log('LocationService: stationary heartbeat '
                '(moved ${distance.toStringAsFixed(1)}m < ${_config.distanceFilterMeters}m)');
          }
        }

        _lastValidPosition = position;

        // Interval: moving = short, stationary = long idle interval.
        final speedMps = position.speed;
        if (!isStationary && speedMps > 2.0) {
          intervalMs = _config.movingIntervalSeconds * 1000;
        } else {
          intervalMs = _config.idleIntervalSeconds * 1000;
        }

        // Emit valid point
        controller.add(
          LocationPoint(
            tripId: tripId,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            speed: position.speed,
            heading: position.heading,
            altitude: position.altitude,
            batteryLevel: null, // battery level retrieved separately if needed
            isGpsEnabled: true,
            isMockLocation: position.isMocked,
            recordedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
      } catch (e) {
        log('LocationService tracking error: $e');
      }

      await Future.delayed(Duration(milliseconds: intervalMs));
    }
  }
}
