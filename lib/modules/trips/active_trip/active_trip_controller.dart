import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/trip_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/trip_service.dart';
import '../../../utils/dialogue_service/dialogues.dart';

class ActiveTripController extends GetxController {
  final TripService _service = TripService();
  final ImagePicker _picker = ImagePicker();

  Rxn<TripModel> trip = Rxn<TripModel>();
  RxList<TripExpenseModel> expenses = <TripExpenseModel>[].obs;
  RxList<TripDocumentModel> documents = <TripDocumentModel>[].obs;

  RxBool isLoadingTrip = false.obs;
  RxBool isLoadingExpenses = false.obs;
  RxBool isUploadingPickup = false.obs;
  RxBool isUploadingReceived = false.obs;
  RxBool isAddingExpense = false.obs;
  RxBool isCompletingTrip = false.obs;
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
    loadTrip();
    loadExpenses();
    loadDocuments();
  }

  Future<void> loadTrip() async {
    isLoadingTrip.value = true;
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
      isLoadingTrip.value = false;
    }
  }

  Future<void> loadExpenses() async {
    isLoadingExpenses.value = true;
    try {
      expenses.value = await _service.getTripExpenses(tripId);
    } catch (_) {
      // silent — expenses list stays empty
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  Future<void> loadDocuments() async {
    try {
      documents.value = await _service.getTripDocuments(tripId);
    } catch (_) {
      // silent — doc list stays empty
    }
  }

  // ── Document Upload ────────────────────────────────────────────────────────

  bool get hasPickupDoc =>
      documents.any((d) => d.documentType.toLowerCase() == 'pickup');

  bool get hasReceivedDoc =>
      documents.any((d) => d.documentType.toLowerCase() == 'received');

  Future<void> uploadPickupDocument() async {
    final source = await _pickImageSource();
    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;

    isUploadingPickup.value = true;
    try {
      final saved = await _service.uploadTripDocument(
        tripId: tripId,
        documentType: 'pickup',
        filePath: image.path,
      );
      if (saved.isNotEmpty) {
        documents.addAll(saved);
        Dialogues.successToast('Pickup document uploaded! Status: Pickup Confirmed.');
        await loadTrip(); // refresh trip status
      } else {
        Dialogues.warningToast('Upload failed. Please try again.');
      }
    } catch (e) {
      Dialogues.warningToast('Error uploading document.');
    } finally {
      isUploadingPickup.value = false;
    }
  }

  Future<void> uploadReceivedDocument() async {
    final source = await _pickImageSource();
    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;

    isUploadingReceived.value = true;
    try {
      final saved = await _service.uploadTripDocument(
        tripId: tripId,
        documentType: 'received',
        filePath: image.path,
      );
      if (saved.isNotEmpty) {
        documents.addAll(saved);
        Dialogues.successToast('Delivery proof uploaded! Trip completed.');
        await loadTrip();
        _navigateToSalary();
      } else {
        Dialogues.warningToast('Upload failed. Please try again.');
      }
    } catch (e) {
      Dialogues.warningToast('Error uploading document.');
    } finally {
      isUploadingReceived.value = false;
    }
  }

  // ── Manual Complete Trip (without requiring a received document) ──────────

  Future<void> completeTrip() async {
    final confirmed = await Dialogues.confirmAsync(
      title: 'Complete Trip?',
      message:
          'Are you sure you want to mark this trip as completed? This action cannot be undone.',
      confirmText: 'Complete',
      cancelText: 'Cancel',
      confirmColor: const Color(0xFF27AE60),
    );
    if (confirmed != true) return;

    isCompletingTrip.value = true;
    try {
      // status 7 = Completed
      final ok = await _service.updateTripStatus(tripId, 7);
      if (ok) {
        Dialogues.successToast('Trip completed!');
        await loadTrip();
        _navigateToSalary();
      } else {
        Dialogues.warningToast('Failed to complete trip. Please retry.');
      }
    } catch (e) {
      debugPrint('completeTrip error: $e');
      Dialogues.warningToast('Something went wrong.');
    } finally {
      isCompletingTrip.value = false;
    }
  }

  void _navigateToSalary() {
    Get.offNamed(AppRoute.salary, arguments: {'tripId': tripId});
  }

  // ── Add Expense ────────────────────────────────────────────────────────────

  Future<void> addExpense({
    required int expenseTypeId,
    required double amount,
    String? notes,
    String? receiptPath,
  }) async {
    isAddingExpense.value = true;
    try {
      final ok = await _service.createTripExpense(
        tripId: tripId,
        expenseTypeId: expenseTypeId,
        amount: amount,
        notes: notes,
        receiptPath: receiptPath,
      );
      if (ok) {
        Dialogues.successToast('Expense added!');
        await loadExpenses();
      } else {
        Dialogues.warningToast('Failed to add expense. Please retry.');
      }
    } catch (e) {
      debugPrint('addExpense error: $e');
      Dialogues.warningToast('Error adding expense.');
    } finally {
      isAddingExpense.value = false;
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void requestAdvance() {
    Get.toNamed(AppRoute.advance, arguments: {'tripId': tripId});
  }

  // ── Image Source Picker ────────────────────────────────────────────────────

  Future<ImageSource?> _pickImageSource() async {
    ImageSource? selected;
    await Get.bottomSheet<void>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1B2A49)),
              title: const Text('Camera'),
              onTap: () { selected = ImageSource.camera; Get.back(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1B2A49)),
              title: const Text('Gallery'),
              onTap: () { selected = ImageSource.gallery; Get.back(); },
            ),
          ],
        ),
      ),
    );
    return selected;
  }
}
