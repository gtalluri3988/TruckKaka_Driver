import 'package:get/get.dart';
import '../../../model/trip_model.dart';
import '../../../services/trip_service.dart';
import '../../../utils/dialogue_service/dialogues.dart';

class AssignedTripsController extends GetxController {
  final TripService _service = TripService();

  RxList<TripModel> trips = <TripModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadTrips();
  }

  Future<void> loadTrips() async {
    isLoading.value = true;
    error.value = '';
    try {
      final all = await _service.getAllTrips();
      // Show only active/pending trips
      trips.value = all
          .where((t) => !t.isCompleted && !t.isCancelled)
          .toList();
    } catch (e) {
      error.value = 'Failed to load trips. Tap retry.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptTrip(int tripId) async {
    try {
      final result = await _service.respondToTrip(tripId: tripId, accept: true);
      if (result != null) {
        Dialogues.successToast('Trip accepted successfully!');
        await loadTrips();
      } else {
        Dialogues.warningToast('Failed to accept trip.');
      }
    } catch (e) {
      Dialogues.warningToast('Error accepting trip.');
    }
  }

  Future<void> rejectTrip(int tripId) async {
    try {
      final result =
          await _service.respondToTrip(tripId: tripId, accept: false);
      if (result != null) {
        Dialogues.infoToast('Trip rejected.');
        await loadTrips();
      }
    } catch (e) {
      Dialogues.warningToast('Error rejecting trip.');
    }
  }
}
