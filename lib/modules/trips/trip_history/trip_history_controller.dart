import 'package:get/get.dart';
import '../../../model/trip_model.dart';
import '../../../services/trip_service.dart';

class TripHistoryController extends GetxController {
  final TripService _service = TripService();

  RxList<TripModel> trips = <TripModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    error.value = '';
    try {
      final all = await _service.getAllTrips();
      // History = completed + cancelled
      trips.value = all
          .where((t) => t.isCompleted || t.isCancelled)
          .toList()
        ..sort((a, b) {
          // Sort by most recent first
          final aDate = a.endDateTime ?? a.startDateTime ?? '';
          final bDate = b.endDateTime ?? b.startDateTime ?? '';
          return bDate.compareTo(aDate);
        });
    } catch (e) {
      error.value = 'Failed to load trip history.';
    } finally {
      isLoading.value = false;
    }
  }
}
