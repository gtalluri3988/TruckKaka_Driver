import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/trip_model.dart';
import '../../services/trip_service.dart';
import '../../utils/dialogue_service/dialogues.dart';

class AdvanceController extends GetxController {
  final TripService _service = TripService();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxList<TripAdvanceModel> advances = <TripAdvanceModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;
  RxString error = ''.obs;
  RxString selectedPaymentMode = 'UPI'.obs;

  int? tripId;

  final List<String> paymentModes = ['UPI', 'Cash', 'Bank Transfer'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    tripId = args?['tripId'] as int?;
  }

  @override
  void onReady() {
    super.onReady();
    if (tripId != null) loadAdvances();
  }

  @override
  void onClose() {
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> loadAdvances() async {
    if (tripId == null) return;
    isLoading.value = true;
    error.value = '';
    try {
      advances.value = await _service.getAdvancesByTrip(tripId!);
    } catch (e) {
      error.value = 'Failed to load advance history.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRequest() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (tripId == null) {
      Dialogues.warningToast('No active trip found. Cannot request advance.');
      return;
    }

    isSubmitting.value = true;
    try {
      final amount = double.tryParse(amountController.text.trim()) ?? 0;
      final result = await _service.requestAdvance(
        tripId: tripId!,
        amount: amount,
        reason: reasonController.text.trim(),
        paymentMode: selectedPaymentMode.value,
      );

      if (result != null) {
        Dialogues.successToast(
          'Advance request submitted! Owner will review soon.',
        );
        amountController.clear();
        reasonController.clear();
        await loadAdvances();
      } else {
        Dialogues.warningToast('Failed to submit request. Please retry.');
      }
    } catch (e) {
      debugPrint('submitAdvance error: $e');
      Dialogues.warningToast('Something went wrong.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
