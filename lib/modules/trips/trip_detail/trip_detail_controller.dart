import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/trip_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/background_tracking_service.dart';
import '../../../services/trip_service.dart';
import '../../../utils/dialogue_service/dialogues.dart';
import '../../../utils/local_storage/stored_data.dart';

class TripDetailController extends GetxController {
  final TripService _service = TripService();
  final ImagePicker _picker = ImagePicker();

  Rxn<TripModel> trip = Rxn<TripModel>();
  RxList<TripAdvanceModel> advances = <TripAdvanceModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isActionLoading = false.obs;
  RxBool isLoadingAdvances = false.obs;
  RxString error = ''.obs;

  late int tripId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    tripId = args?['tripId'] as int? ?? 0;
    loadTrip();
  }

  Future<void> loadTrip() async {
    isLoading.value = true;
    error.value = '';
    try {
      final t = await _service.getTripById(tripId);
      if (t != null) {
        trip.value = t;
        loadAdvances();
      } else {
        error.value = 'Trip not found.';
      }
    } catch (e) {
      error.value = 'Failed to load trip details.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAdvances() async {
    isLoadingAdvances.value = true;
    try {
      advances.value = await _service.getAdvancesByTrip(tripId);
    } catch (_) {
      // Silently fail — advances section will show "no advances"
    } finally {
      isLoadingAdvances.value = false;
    }
  }

  // ── Driver Actions ─────────────────────────────────────────────────────────

  Future<void> startTrip() async {
    await _performAction(() async {
      // Ensure location permission BEFORE starting the background service —
      // the foreground-service isolate cannot show a permission dialog itself.
      final permissionOk = await _ensureLocationPermission();
      if (!permissionOk) return;

      // status 4 = Started
      final ok = await _service.updateTripStatus(tripId, 4);
      if (ok) {
        // Start background GPS tracking
        final token = await StoredData.getTokenModel();
        final driverIdInt = int.tryParse(token?.userId ?? '') ?? 0;
        if (driverIdInt > 0) {
          await BackgroundTrackingService.startTracking(tripId, driverIdInt);
        }
        Dialogues.successToast('Trip started! GPS tracking enabled.');
        Get.toNamed(AppRoute.activeTrip, arguments: {'tripId': tripId});
      } else {
        Dialogues.warningToast('Could not start trip. Please retry.');
      }
    });
  }

  /// Request foreground + background location permission from the UI.
  /// Must run from main isolate — a background service isolate cannot
  /// show the system permission dialog.
  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Dialogues.warningToast('Please turn on GPS/Location to start the trip.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Dialogues.warningToast(
        'Location permission is required to track this trip.',
      );
      return false;
    }

    // Android 10+ requires background location granted separately.
    // Prompt user if we only have "while in use".
    if (permission == LocationPermission.whileInUse) {
      Dialogues.warningToast(
        'Please set location permission to "Allow all the time" '
        'so tracking continues in the background.',
      );
    }
    return true;
  }

  void goToActiveTrip() {
    Get.toNamed(AppRoute.activeTrip, arguments: {'tripId': tripId});
  }

  Future<void> confirmPickup() async {
    await _performAction(() async {
      final result = await _service.confirmPickup(tripId);
      if (result != null) {
        trip.value = result;
        Dialogues.successToast(
          'Pickup confirmed! Trip cancellation is now locked.',
        );
      } else {
        Dialogues.warningToast('Failed to confirm pickup. Please retry.');
      }
    });
  }

  Future<void> completeTrip() async {
    // Pick delivery proof image first
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image == null) {
      Dialogues.warningToast('Please capture delivery proof to complete.');
      return;
    }

    await _performAction(() async {
      // Upload proof
      final uploaded = await _service.uploadTripImages(
        tripId: tripId,
        imageType: 'unloading',
        filePaths: [image.path],
      );

      if (!uploaded) {
        Dialogues.warningToast('Image upload failed. Try again.');
        return;
      }

      // Stop background GPS tracking
      await BackgroundTrackingService.stopTracking();

      // status 7 = Completed
      final ok = await _service.updateTripStatus(tripId, 7);
      if (ok) {
        Dialogues.successToast(
          'Trip completed! Salary request is now pending.',
        );
        await loadTrip();
        Get.offNamed(AppRoute.salary, arguments: {'tripId': tripId});
      } else {
        Dialogues.warningToast('Failed to complete trip. Please retry.');
      }
    });
  }

  Future<void> requestAdvance() async {
    await Get.toNamed(AppRoute.advance, arguments: {'tripId': tripId});
    await loadAdvances(); // Refresh advances on return from advance screen
  }

  Future<void> _performAction(Future<void> Function() action) async {
    isActionLoading.value = true;
    try {
      await action();
    } catch (e) {
      debugPrint('tripAction error: $e');
      Dialogues.warningToast('Something went wrong. Please try again.');
    } finally {
      isActionLoading.value = false;
    }
  }
}
