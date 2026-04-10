import 'dart:developer';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../api/api_url.dart';
import '../model/trip_model.dart';

class TripService {
  // ── Fetch Trips ────────────────────────────────────────────────────────────

  /// All trips for the current driver (history + active).
  Future<List<TripModel>> getAllTrips() async {
    try {
      final res = await ApiService.get(url: ApiUrl.getAllTrips);
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data['result'] as List? ?? [];
        return list
            .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('getAllTrips error: $e');
    }
    return [];
  }

  /// Single trip details by ID.
  Future<TripModel?> getTripById(int tripId) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.getTripDetailsById,
        queryParameters: {'tripId': tripId},
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['result'] ?? res.data;
        return TripModel.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      log('getTripById error: $e');
    }
    return null;
  }

  /// Check for an active assigned trip on login/dashboard load.
  /// Returns null if no active trip.
  Future<TripModel?> getActiveAssignedTrip() async {
    try {
      final res = await ApiService.get(url: ApiUrl.getActiveAssignedTrip);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data;
        // API returns { hasActiveTrip: bool, trip: TripDTO? }
        final bool hasActive = data['hasActiveTrip'] as bool? ?? false;
        if (hasActive && data['trip'] != null) {
          return TripModel.fromJson(data['trip'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('getActiveAssignedTrip error: $e');
    }
    return null;
  }

  // ── Driver Actions ─────────────────────────────────────────────────────────

  /// Accept or reject a trip assignment.
  /// [accept] = true → accepted, false → rejected.
  Future<TripModel?> respondToTrip({
    required int tripId,
    required bool accept,
  }) async {
    try {
      final res = await ApiService.post(
        url: ApiUrl.driverResponse,
        data: {'tripId': tripId, 'accept': accept},
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['trip'] ?? res.data['result'];
        if (data != null) {
          return TripModel.fromJson(data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('respondToTrip error: $e');
    }
    return null;
  }

  /// Update trip status (e.g., start trip = status 2, complete = status 4).
  Future<bool> updateTripStatus(int tripId, int status) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.updateTripStatus,
        queryParameters: {'tripId': tripId, 'status': status},
      );
      return res.statusCode == 200;
    } catch (e) {
      log('updateTripStatus error: $e');
      return false;
    }
  }

  /// Confirm pickup — locks the trip (no cancellation after this).
  Future<TripModel?> confirmPickup(int tripId) async {
    try {
      final res = await ApiService.post(
        url: ApiUrl.confirmPickup,
        data: {'tripId': tripId},
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['result'];
        if (data != null) {
          return TripModel.fromJson(data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('confirmPickup error: $e');
    }
    return null;
  }

  // ── Upload Trip Images ─────────────────────────────────────────────────────

  /// Upload images for pickup/delivery (LR, POD, etc.).
  Future<bool> uploadTripImages({
    required int tripId,
    required String imageType,
    required List<String> filePaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        'tripId': tripId,
        'tripImageType': imageType,
        'files': [
          for (final path in filePaths)
            await MultipartFile.fromFile(path),
        ],
      });
      final res = await ApiService.postWithFormData(
        url: ApiUrl.saveTripImages,
        data: formData,
      );
      return res.statusCode == 200;
    } catch (e) {
      log('uploadTripImages error: $e');
      return false;
    }
  }

  // ── Advance Requests ───────────────────────────────────────────────────────

  /// Submit a new advance request.
  Future<TripAdvanceModel?> requestAdvance({
    required int tripId,
    required double amount,
    required String reason,
    String paymentMode = 'UPI',
  }) async {
    try {
      final res = await ApiService.post(
        url: ApiUrl.saveAdvanceRequest,
        data: {
          'tripId': tripId,
          'requestedAmount': amount,
          'requestorComments': reason,
          'paymentMode': paymentMode,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['result'];
        if (data != null) {
          return TripAdvanceModel.fromJson(data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('requestAdvance error: $e');
    }
    return null;
  }

  /// Get all advance requests for a trip.
  Future<List<TripAdvanceModel>> getAdvancesByTrip(int tripId) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.getTripAdvanceByTripId,
        queryParameters: {'tripId': tripId},
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data['result'] as List? ?? res.data as List? ?? [];
        return list
            .map((e) => TripAdvanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('getAdvancesByTrip error: $e');
    }
    return [];
  }

  // ── Transaction Summary ────────────────────────────────────────────────────

  /// Full transaction/salary summary for a trip.
  Future<TripTransactionModel?> getTripTransactions(int tripId) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.getTripTransactions,
        queryParameters: {'tripId': tripId},
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['result'] ?? res.data;
        return TripTransactionModel.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      log('getTripTransactions error: $e');
    }
    return null;
  }

  /// Get current salary approval status for a trip.
  Future<int?> getSalaryStatus(int tripId) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.getCurrentSalaryStatus,
        queryParameters: {'tripId': tripId},
      );
      if (res.statusCode == 200) {
        return res.data['result'] as int?;
      }
    } catch (e) {
      log('getSalaryStatus error: $e');
    }
    return null;
  }
}
