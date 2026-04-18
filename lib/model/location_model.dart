/// Single GPS location point for offline queue and API upload.
class LocationPoint {
  final int? id; // SQLite local ID
  final int tripId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed; // m/s
  final double? heading; // degrees 0-360
  final double? altitude;
  final int? batteryLevel; // 0-100
  final bool isGpsEnabled;
  final bool isMockLocation;
  final String recordedAt; // ISO 8601 UTC
  final bool synced;

  LocationPoint({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
    this.batteryLevel,
    this.isGpsEnabled = true,
    this.isMockLocation = false,
    required this.recordedAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'altitude': altitude,
        'batteryLevel': batteryLevel,
        'isGpsEnabled': isGpsEnabled,
        'isMockLocation': isMockLocation,
        'recordedAt': recordedAt,
      };

  Map<String, dynamic> toDbRow() => {
        'trip_id': tripId,
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'altitude': altitude,
        'battery': batteryLevel,
        'is_gps_enabled': isGpsEnabled ? 1 : 0,
        'is_mock': isMockLocation ? 1 : 0,
        'recorded_at': recordedAt,
        'synced': synced ? 1 : 0,
      };

  factory LocationPoint.fromDbRow(Map<String, dynamic> row) {
    return LocationPoint(
      id: row['id'] as int?,
      tripId: row['trip_id'] as int,
      latitude: (row['lat'] as num).toDouble(),
      longitude: (row['lng'] as num).toDouble(),
      accuracy: (row['accuracy'] as num?)?.toDouble(),
      speed: (row['speed'] as num?)?.toDouble(),
      heading: (row['heading'] as num?)?.toDouble(),
      altitude: (row['altitude'] as num?)?.toDouble(),
      batteryLevel: row['battery'] as int?,
      isGpsEnabled: (row['is_gps_enabled'] as int?) == 1,
      isMockLocation: (row['is_mock'] as int?) == 1,
      recordedAt: row['recorded_at'] as String,
      synced: (row['synced'] as int?) == 1,
    );
  }
}

/// Response from POST /api/Tracking/BulkUpload.
class BulkUploadResponse {
  final bool success;
  final String message;
  final int pointsAccepted;
  final int pointsRejected;
  final String? serverTime;
  final TrackingConfig? config;

  BulkUploadResponse({
    required this.success,
    required this.message,
    this.pointsAccepted = 0,
    this.pointsRejected = 0,
    this.serverTime,
    this.config,
  });

  factory BulkUploadResponse.fromJson(Map<String, dynamic> json) {
    return BulkUploadResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      pointsAccepted: json['pointsAccepted'] as int? ?? 0,
      pointsRejected: json['pointsRejected'] as int? ?? 0,
      serverTime: json['serverTime'] as String?,
      config: json['config'] != null
          ? TrackingConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Server-configurable tracking parameters.
class TrackingConfig {
  final int movingIntervalSeconds;
  final int idleIntervalSeconds;
  final double accuracyThresholdMeters;
  final double distanceFilterMeters;
  final int batchSizeLimit;

  TrackingConfig({
    this.movingIntervalSeconds = 15,
    this.idleIntervalSeconds = 120,
    this.accuracyThresholdMeters = 50,
    this.distanceFilterMeters = 10,
    this.batchSizeLimit = 50,
  });

  factory TrackingConfig.fromJson(Map<String, dynamic> json) {
    return TrackingConfig(
      movingIntervalSeconds: json['movingIntervalSeconds'] as int? ?? 15,
      idleIntervalSeconds: json['idleIntervalSeconds'] as int? ?? 120,
      accuracyThresholdMeters:
          (json['accuracyThresholdMeters'] as num?)?.toDouble() ?? 50,
      distanceFilterMeters:
          (json['distanceFilterMeters'] as num?)?.toDouble() ?? 10,
      batchSizeLimit: json['batchSizeLimit'] as int? ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
        'movingIntervalSeconds': movingIntervalSeconds,
        'idleIntervalSeconds': idleIntervalSeconds,
        'accuracyThresholdMeters': accuracyThresholdMeters,
        'distanceFilterMeters': distanceFilterMeters,
        'batchSizeLimit': batchSizeLimit,
      };
}
