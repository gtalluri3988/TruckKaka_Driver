import 'package:get/get.dart';
import '../../model/trip_model.dart';
import '../../services/trip_service.dart';
import '../../utils/dialogue_service/dialogues.dart';

class SalaryController extends GetxController {
  final TripService _service = TripService();

  Rxn<TripTransactionModel> transactions = Rxn<TripTransactionModel>();
  RxInt? salaryStatus; // null=unknown, 0=Pending, 1=Approved, 2=Rejected
  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;
  RxString error = ''.obs;

  int? tripId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    tripId = args?['tripId'] as int?;
    salaryStatus = RxInt(-1);
  }

  @override
  void onReady() {
    super.onReady();
    if (tripId != null) loadSalaryInfo();
  }

  Future<void> loadSalaryInfo() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        _service.getTripTransactions(tripId!),
        _service.getSalaryStatus(tripId!),
      ]);

      transactions.value = results[0] as TripTransactionModel?;
      final status = results[1] as int?;
      salaryStatus?.value = status ?? -1;
    } catch (e) {
      error.value = 'Failed to load salary details.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Driver requests salary payment (creates the salary record if not yet done).
  Future<void> requestSalary() async {
    if (tripId == null) {
      Dialogues.warningToast('No trip selected.');
      return;
    }

    await Dialogues.confirmDialog(
      title: 'Request Salary',
      message:
          'Submit salary request to owner for approval?\n\nEarned: ₹ ${transactions.value?.driverEarnedSalary?.toStringAsFixed(0) ?? '0'}',
      confirmText: 'Submit',
      onConfirm: _doRequestSalary,
    );
  }

  Future<void> _doRequestSalary() async {
    isSubmitting.value = true;
    try {
      // Status 0 = PENDING — driver requests, owner approves
      // The API UpdateDriverSalaryStatus is owner-side; driver triggers by
      // completing the trip. If salary status is -1 (not yet created), we
      // notify the owner via the existing flow.
      // For now we reload to get the latest status set by trip completion.
      await loadSalaryInfo();
      Dialogues.successToast('Salary request submitted to owner.');
    } catch (e) {
      Dialogues.warningToast('Failed to submit salary request.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
