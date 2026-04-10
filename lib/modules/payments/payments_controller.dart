import 'package:get/get.dart';
import '../../model/trip_model.dart';
import '../../services/trip_service.dart';
import '../../utils/local_storage/stored_data.dart';

class PaymentsController extends GetxController {
  final TripService _service = TripService();

  RxList<TripModel> completedTrips = <TripModel>[].obs;
  RxList<TripAdvanceModel> allAdvances = <TripAdvanceModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  // Summary
  RxDouble totalEarned = 0.0.obs;
  RxDouble totalAdvances = 0.0.obs;
  RxDouble pendingBalance = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    loadPaymentSummary();
  }

  Future<void> loadPaymentSummary() async {
    isLoading.value = true;
    error.value = '';
    try {
      final trips = await _service.getAllTrips();
      completedTrips.value = trips.where((t) => t.isCompleted).toList();

      // Calculate summary from completed trips
      double earned = 0;
      double advances = 0;
      for (final trip in completedTrips) {
        earned += trip.salaryAmount ?? 0;
        advances += trip.approvedAmount ?? 0;
      }
      totalEarned.value = earned;
      totalAdvances.value = advances;
      pendingBalance.value = earned - advances;
    } catch (e) {
      error.value = 'Failed to load payment summary.';
    } finally {
      isLoading.value = false;
    }
  }
}
