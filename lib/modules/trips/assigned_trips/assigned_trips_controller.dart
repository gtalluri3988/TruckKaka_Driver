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

  /// Trips awaiting driver acceptance (status = Planned / PendingDriverAcceptance).
  List<TripModel> get pendingTrips =>
      trips.where((t) => t.isPendingAcceptance).toList();

  /// Active trips already accepted / ongoing.
  List<TripModel> get acceptedTrips =>
      trips.where((t) => !t.isPendingAcceptance).toList();

  Future<void> loadTrips() async {
    isLoading.value = true;
    error.value = '';
    try {
      final all = await _service.getAllTrips();
      // Keep only active trips (exclude completed, cancelled, driver-rejected)
      trips.value = all
          .where((t) => !t.isCompleted && !t.isCancelled && !t.isDriverRejected)
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
