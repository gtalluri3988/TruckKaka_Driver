import 'package:get/get.dart';
import '../../../model/trip_model.dart';
import '../../../services/trip_service.dart';

class TripHistoryDetailController extends GetxController {
  final TripService _service = TripService();

  Rxn<TripModel> trip = Rxn<TripModel>();
  RxList<TripExpenseModel> expenses = <TripExpenseModel>[].obs;
  RxList<TripAdvanceModel> advances = <TripAdvanceModel>[].obs;
  Rxn<TripTransactionModel> transactions = Rxn<TripTransactionModel>();

  RxBool isLoadingTrip = false.obs;
  RxBool isLoadingDetails = false.obs;
  RxString error = ''.obs;

  late int tripId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    tripId = args?['tripId'] as int? ?? 0;
  }

  @override
  void onReady() {
    super.onReady();
    loadAll();
  }

  Future<void> loadAll() async {
    await _loadTrip();
    if (error.value.isEmpty) {
      await _loadDetails();
    }
  }

  Future<void> _loadTrip() async {
    isLoadingTrip.value = true;
    error.value = '';
    try {
      final t = await _service.getTripById(tripId);
      if (t != null) {
        trip.value = t;
      } else {
        error.value = 'Trip not found.';
      }
    } catch (_) {
      error.value = 'Failed to load trip details.';
    } finally {
      isLoadingTrip.value = false;
    }
  }

  Future<void> _loadDetails() async {
    isLoadingDetails.value = true;
    await Future.wait([
      _service
          .getTripExpenses(tripId)
          .then((v) { expenses.value = v; })
          .catchError((dynamic _) {}),
      _service
          .getAdvancesByTrip(tripId)
          .then((v) { advances.value = v; })
          .catchError((dynamic _) {}),
      _service
          .getTripTransactions(tripId)
          .then((v) { if (v != null) transactions.value = v; })
          .catchError((dynamic _) {}),
    ]);
    isLoadingDetails.value = false;
  }
}
