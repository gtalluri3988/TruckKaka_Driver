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
      // History = completed trips only, sorted most recent first
      trips.value = all
          .where((t) => t.isCompleted)
          .toList()
        ..sort((a, b) {
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

  // ── Stats ─────────────────────────────────────────────────────────────────

  int get totalTripsCount => trips.length;

  String get totalEarnedDisplay {
    final total = trips.fold(0.0, (s, t) => s + t.earningsAmount).toInt();
    return '₹${_fmtNum(total)}';
  }

  String get totalDistanceDisplay {
    final km = trips.fold(0, (s, t) => s + (t.distance ?? 0));
    return '${_fmtNum(km)} km';
  }

  static String _fmtNum(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
