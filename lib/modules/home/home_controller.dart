import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../model/trip_model.dart';
import '../../routes/app_routes.dart';
import '../../services/background_tracking_service.dart';
import '../../services/trip_service.dart';
import '../../utils/dialogue_service/dialogues.dart';
import '../../utils/local_storage/stored_data.dart';

class HomeController extends GetxController {
  final TripService _tripService = TripService();

  Rxn<TripModel> activeTrip = Rxn<TripModel>();
  RxBool isCheckingTrip = false.obs;

  // Driver info
  RxString driverName = ''.obs;
  RxString driverId = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _loadDriverInfo();
    _checkActiveTrip();
  }

  Future<void> _loadDriverInfo() async {
    final tokenModel = await StoredData.getTokenModel();
    driverName.value = tokenModel?.fullName ?? 'Driver';
    driverId.value = tokenModel?.userId ?? '';
  }

  /// Called on every dashboard open — checks for a pending trip assignment.
  Future<void> _checkActiveTrip() async {
    isCheckingTrip.value = true;
    try {
      final trip = await _tripService.getActiveAssignedTrip();
      if (trip != null) {
        activeTrip.value = trip;
        // Show accept/reject dialog if trip is pending acceptance
        if (trip.isPendingAcceptance) {
          await _showTripAssignedDialog(trip);
        }
        // Resume background tracking if trip is ongoing.
        // We ALWAYS verify permission in the UI first — the background
        // isolate cannot show the system dialog, so if permission was
        // revoked or never granted, the service silently dies and
        // isRunning() can still return true (zombie container).
        if (trip.isOnGoing && driverId.value.isNotEmpty) {
          final isTracking = await BackgroundTrackingService.isRunning();
          debugPrint(
            'HomeController: active trip ${trip.tripId} isOnGoing, '
            'service running=$isTracking',
          );

          final permissionOk = await _ensureLocationPermission();
          if (!permissionOk) {
            // Tear down any zombie service — it can't collect GPS
            // without permission and will keep crashing silently.
            if (isTracking) {
              await BackgroundTrackingService.stopTracking();
            }
            return;
          }

          // Permission is granted — always call startTracking so any zombie
          // isolate from a previous APK install gets force-restarted with
          // the current code. startTracking handles the idempotent case.
          await BackgroundTrackingService.startTracking(
            trip.tripId ?? 0,
            int.tryParse(driverId.value) ?? 0,
          );
          debugPrint(
            'HomeController: tracking (re)started for trip ${trip.tripId}',
          );
        }
      }
    } catch (e) {
      debugPrint('checkActiveTrip error: $e');
    } finally {
      isCheckingTrip.value = false;
    }
  }

  Future<void> refreshActiveTrip() => _checkActiveTrip();

  // Track whether we've already nudged the user this session to avoid
  // spamming the same dialog every time _checkActiveTrip fires.
  bool _permissionDialogShown = false;

  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Dialogues.warningToast('Please turn on GPS/Location for trip tracking.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await _showOpenSettingsDialog(
        title: 'Location Permission Required',
        body:
            'Background GPS tracking is required for your active trip. '
            'Please enable location permission for this app.',
      );
      return false;
    }

    // Android 11+: "While using the app" = GPS stops as soon as the app
    // is backgrounded, which kills tracking. We need "Allow all the time".
    if (permission != LocationPermission.always) {
      await _showOpenSettingsDialog(
        title: 'Background Location Required',
        body:
            'Please change location permission to "Allow all the time". '
            'Without it, GPS tracking stops when you leave the app.',
      );
      return false;
    }

    return true;
  }

  Future<void> _showOpenSettingsDialog({
    required String title,
    required String body,
  }) async {
    if (_permissionDialogShown) return;
    _permissionDialogShown = true;

    await Get.dialog<void>(
      AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Not now')),
          TextButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showTripAssignedDialog(TripModel trip) async {
    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (ctx) => _TripAssignedDialog(trip: trip, controller: this),
    );
  }

  Future<void> acceptTrip(int tripId) async {
    try {
      final result = await _tripService.respondToTrip(
        tripId: tripId,
        accept: true,
      );
      if (result != null) {
        activeTrip.value = result;
        Dialogues.successToast('Trip accepted! Tracking enabled.');
        Get.toNamed(AppRoute.tripDetail, arguments: {'tripId': tripId});
      } else {
        Dialogues.warningToast('Failed to accept trip. Please try again.');
      }
    } catch (e) {
      Dialogues.warningToast('Error accepting trip.');
    }
  }

  Future<void> rejectTrip(int tripId) async {
    try {
      final result = await _tripService.respondToTrip(
        tripId: tripId,
        accept: false,
      );
      if (result != null) {
        activeTrip.value = null;
        Dialogues.infoToast('Trip rejected.');
      }
    } catch (e) {
      Dialogues.warningToast('Error rejecting trip.');
    }
  }
}

// ── Trip Assigned Popup ────────────────────────────────────────────────────────

class _TripAssignedDialog extends StatefulWidget {
  final TripModel trip;
  final HomeController controller;

  const _TripAssignedDialog({required this.trip, required this.controller});

  @override
  State<_TripAssignedDialog> createState() => _TripAssignedDialogState();
}

class _TripAssignedDialogState extends State<_TripAssignedDialog> {
  bool isAccepting = false;
  bool isRejecting = false;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2A49).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Color(0xFF1B2A49),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Trip Assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2A49),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A new trip has been assigned to you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Trip info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.my_location_rounded,
                  label: 'From',
                  value: trip.startLocation ?? '—',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'To',
                  value: trip.endLocation ?? '—',
                ),
                if (trip.vehicleRegNo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.directions_car_rounded,
                    label: 'Vehicle',
                    value: trip.vehicleRegNo,
                  ),
                ],
                if (trip.loadDescription != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.inventory_2_rounded,
                    label: 'Load',
                    value: trip.loadDescription!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tracking consent
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By accepting, you consent to GPS tracking during this trip.',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Accept / Reject
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      isRejecting || isAccepting
                          ? null
                          : () async {
                            setState(() => isRejecting = true);
                            Navigator.pop(context);
                            await widget.controller.rejectTrip(
                              trip.tripId ?? 0,
                            );
                          },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      isRejecting
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.redAccent,
                            ),
                          )
                          : const Text(
                            'Reject',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isAccepting || isRejecting
                          ? null
                          : () async {
                            setState(() => isAccepting = true);
                            Navigator.pop(context);
                            await widget.controller.acceptTrip(
                              trip.tripId ?? 0,
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A49),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      isAccepting
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF274472)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF274472),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
