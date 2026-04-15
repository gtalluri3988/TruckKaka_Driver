import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/trip_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/trip_service.dart';
import '../../../utils/dialogue_service/dialogues.dart';

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
      // status 4 = Started
      final ok = await _service.updateTripStatus(tripId, 4);
      if (ok) {
        Dialogues.successToast('Trip started! GPS tracking enabled.');
        Get.toNamed(AppRoute.activeTrip, arguments: {'tripId': tripId});
      } else {
        Dialogues.warningToast('Could not start trip. Please retry.');
      }
    });
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
