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
  RxBool isLoading = false.obs;
  RxBool isActionLoading = false.obs;
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
      } else {
        error.value = 'Trip not found.';
      }
    } catch (e) {
      error.value = 'Failed to load trip details.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Driver Actions ─────────────────────────────────────────────────────────

  Future<void> startTrip() async {
    await _performAction(() async {
      // status 2 = Started/OnGoing (based on TripStatusEnum)
      final ok = await _service.updateTripStatus(tripId, 2);
      if (ok) {
        Dialogues.successToast('Trip started! GPS tracking enabled.');
        await loadTrip();
      } else {
        Dialogues.warningToast('Could not start trip. Please retry.');
      }
    });
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

      // status 4 = Completed
      final ok = await _service.updateTripStatus(tripId, 4);
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
    Get.toNamed(AppRoute.advance, arguments: {'tripId': tripId});
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
