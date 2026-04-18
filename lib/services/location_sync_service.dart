import '../api/api_service.dart';
import '../api/api_url.dart';
import '../model/location_model.dart';
import 'location_queue_service.dart';

/// Handles batch HTTP upload of queued GPS locations to the API.
class LocationSyncService {
  /// Upload a batch of location points to the server.
  /// Returns the server response with updated config, or null on failure.
  static Future<BulkUploadResponse?> uploadBatch(
    int tripId,
    List<LocationPoint> points,
  ) async {
    if (points.isEmpty) return null;

    try {
      final payload = {
        'tripId': tripId,
        'points': points.map((p) => p.toJson()).toList(),
      };

      // ignore: avoid_print
      print('LocationSync: POST ${ApiUrl.trackingBulkUpload} '
          'tripId=$tripId points=${points.length}');

      final res = await ApiService.post(
        url: ApiUrl.trackingBulkUpload,
        data: payload,
      );

      // ignore: avoid_print
      print('LocationSync: response status=${res.statusCode} data=${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        return BulkUploadResponse.fromJson(
          res.data is Map<String, dynamic>
              ? res.data as Map<String, dynamic>
              : {},
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('LocationSync: uploadBatch error: $e');
    }
    return null;
  }

  /// Dequeue pending points and attempt to sync them with the server.
  /// If upload succeeds, marks the points as synced. If it fails,
  /// the points remain in the queue for the next attempt.
  static Future<TrackingConfig?> syncPendingLocations(
    int tripId, {
    int batchSize = 50,
  }) async {
    try {
      final pending = await LocationQueueService.getUnsyncedBatch(batchSize);
      // ignore: avoid_print
      print('LocationSync: ${pending.length} pending points in queue');
      if (pending.isEmpty) return null;

      final response = await uploadBatch(tripId, pending);
      if (response != null && response.success) {
        // Mark as synced
        final ids = pending
            .where((p) => p.id != null)
            .map((p) => p.id!)
            .toList();
        await LocationQueueService.markSynced(ids);

        // Cleanup old synced data periodically
        await LocationQueueService.cleanup();

        // ignore: avoid_print
        print('LocationSync: ${response.pointsAccepted} points synced, '
            '${response.pointsRejected} rejected');

        return response.config;
      } else {
        // ignore: avoid_print
        print('LocationSync: upload failed or returned success=false — '
            'points remain in queue');
      }
    } catch (e) {
      // ignore: avoid_print
      print('LocationSync: syncPendingLocations error: $e');
    }
    return null;
  }

  /// Fetch the latest tracking configuration from the server.
  static Future<TrackingConfig?> fetchConfig() async {
    try {
      final res = await ApiService.get(url: ApiUrl.trackingConfig);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['result'] ?? res.data;
        return TrackingConfig.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      // ignore: avoid_print
      print('LocationSync: fetchConfig error: $e');
    }
    return null;
  }
}
