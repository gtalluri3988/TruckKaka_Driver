import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/trip_model.dart';
import '../../../utils/dialogue_service/dialogues.dart';
import 'active_trip_controller.dart';

class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveTripController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Obx(() {
          final trip = controller.trip.value;
          return AppBar(
            backgroundColor: const Color(0xFF1B2A49),
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: Get.back,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Details',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trip != null)
                  Text(
                    'ID: ${trip.tripCode ?? 'T#${trip.tripId}'}',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () {
                  controller.loadTrip();
                  controller.loadExpenses();
                  controller.loadDocuments();
                },
              ),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoadingTrip.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B2A49)),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  controller.error.value,
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A49),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        final trip = controller.trip.value;
        if (trip == null) return const SizedBox.shrink();

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  // ── Trip Status Card ─────────────────────────────────────
                  _TripStatusCard(trip: trip),
                  const SizedBox(height: 16),

                  // ── Documents Card ───────────────────────────────────────
                  _DocumentsCard(controller: controller),
                  const SizedBox(height: 16),

                  // ── Expenses Card ────────────────────────────────────────
                  _ExpensesCard(controller: controller),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Bottom Buttons ────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, 24 + MediaQuery.of(context).padding.bottom),
              color: const Color(0xFFF4F6FB),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Request Advance — green filled button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: controller.requestAdvance,
                      icon: const Icon(Icons.attach_money_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        'Request Advance for Current Trip',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Complete Trip — outlined button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: controller.isCompletingTrip.value
                              ? null
                              : controller.completeTrip,
                          icon: controller.isCompletingTrip.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1B2A49),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 20,
                                  color: Color(0xFF1B2A49),
                                ),
                          label: Text(
                            'Complete Trip',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B2A49),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1B2A49),
                            side: const BorderSide(
                                color: Color(0xFF1B2A49), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Trip Status Card ──────────────────────────────────────────────────────────

class _TripStatusCard extends StatelessWidget {
  final TripModel trip;

  const _TripStatusCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Trip Status + badge ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  'Trip Status',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                const Spacer(),
                _StatusChip(status: trip.status),
              ],
            ),
          ),

          // ── Live Tracking Banner ──────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.near_me_rounded,
                    color: Color(0xFF27AE60), size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Tracking Active',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF27AE60),
                      ),
                    ),
                    Text(
                      'Location shared with owner',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF27AE60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Started-at info row ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Started at:  ',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                Expanded(
                  child: Text(
                    _startedAtDisplay(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2A49),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Pickup ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF27AE60),
              label: 'Pickup',
              address: trip.pickupDisplay,
            ),
          ),

          // ── Drop ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: Colors.redAccent,
              label: 'Drop',
              address: trip.dropDisplay,
            ),
          ),

          // ── Distance / Duration ───────────────────────────────────────
          if (trip.distanceDurationDisplay.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                trip.distanceDurationDisplay,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _startedAtDisplay() {
    final raw = trip.tripStartTime ?? trip.startDateTime;
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw).toLocal();
      final h = d.hour > 12
          ? d.hour - 12
          : (d.hour == 0 ? 12 : d.hour);
      final mm = d.minute.toString().padLeft(2, '0');
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '$h:$mm $ampm';
    } catch (_) {
      return raw;
    }
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'started':
      case 'ongoing':
        return const Color(0xFFE67E22);
      case 'pickupconfirmed':
        return const Color(0xFF8E44AD);
      case 'intransit':
        return const Color(0xFF2980B9);
      case 'driveraccepted':
      case 'accepted':
        return const Color(0xFF27AE60);
      case 'completed':
        return const Color(0xFF16A085);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return const Color(0xFFE67E22);
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return 'Started';
      case 'pickupconfirmed':
        return 'Pickup Confirmed';
      case 'intransit':
        return 'In Transit';
      case 'driveraccepted':
        return 'Accepted';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

// ── Location Row ──────────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1B2A49),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Documents Card ────────────────────────────────────────────────────────────

class _DocumentsCard extends StatelessWidget {
  final ActiveTripController controller;

  const _DocumentsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Documents',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B2A49),
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Pickup Documents Row ──────────────────────────────────────
          Obx(() {
            final pickupDocs = controller.documents
                .where((d) => d.isPickup)
                .toList();
            return _DocRow(
              title: 'Pickup Documents',
              subtitle: 'LR / POD / Order papers',
              icon: Icons.upload_file_rounded,
              uploadedDocs: pickupDocs,
              isUploading: controller.isUploadingPickup.value,
              onUpload: () async {
                final confirmed = await Dialogues.confirmAsync(
                  title: 'Upload Pickup Document?',
                  message:
                      'Uploading will confirm your pickup and update trip status to Pickup Confirmed.',
                  confirmText: 'Upload',
                  cancelText: 'Cancel',
                  confirmColor: const Color(0xFF1B2A49),
                );
                if (confirmed == true) {
                  controller.uploadPickupDocument();
                }
              },
            );
          }),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Received Documents Row ────────────────────────────────────
          Obx(() {
            final receivedDocs = controller.documents
                .where((d) => d.isReceived)
                .toList();
            return _DocRow(
              title: 'Delivery Proof',
              subtitle: 'Delivery receipt / POD',
              icon: Icons.fact_check_outlined,
              uploadedDocs: receivedDocs,
              isUploading: controller.isUploadingReceived.value,
              onUpload: () async {
                final confirmed = await Dialogues.confirmAsync(
                  title: 'Upload Delivery Proof?',
                  message:
                      'Uploading delivery proof will mark this trip as Completed. This action cannot be undone.',
                  confirmText: 'Upload',
                  cancelText: 'Cancel',
                  confirmColor: const Color(0xFF27AE60),
                );
                if (confirmed == true) {
                  controller.uploadReceivedDocument();
                }
              },
            );
          }),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Doc Row ───────────────────────────────────────────────────────────────────

class _DocRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isUploading;
  final VoidCallback onUpload;
  final List<TripDocumentModel> uploadedDocs;

  const _DocRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isUploading,
    required this.onUpload,
    required this.uploadedDocs,
  });

  @override
  Widget build(BuildContext context) {
    final hasUploaded = uploadedDocs.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasUploaded
                      ? const Color(0xFFE8F8F0)
                      : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasUploaded ? Icons.check_circle_rounded : icon,
                  color: hasUploaded
                      ? const Color(0xFF27AE60)
                      : Colors.grey.shade500,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B2A49),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Upload button
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: isUploading ? null : onUpload,
                  icon: isUploading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          hasUploaded
                              ? Icons.add_photo_alternate_outlined
                              : Icons.upload_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                  label: Text(
                    hasUploaded ? 'Add More' : 'Upload',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasUploaded
                        ? const Color(0xFF27AE60)
                        : const Color(0xFF1B2A49),
                    disabledBackgroundColor:
                        const Color(0xFF1B2A49).withValues(alpha: 0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ── Uploaded files list ────────────────────────────────────
          if (hasUploaded) ...[
            const SizedBox(height: 10),
            ...uploadedDocs.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const SizedBox(width: 54), // align under title
                    Icon(Icons.insert_drive_file_outlined,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doc.originalFileName ?? 'Document',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      doc.uploadedAtDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Expenses Card ─────────────────────────────────────────────────────────────

class _ExpensesCard extends StatelessWidget {
  final ActiveTripController controller;

  const _ExpensesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                Text(
                  'Trip Expenses',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                const Spacer(),
                Obx(() => ElevatedButton(
                      onPressed: controller.isAddingExpense.value
                          ? null
                          : () => _showAddExpenseSheet(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2A49),
                        disabledBackgroundColor:
                            const Color(0xFF1B2A49).withValues(alpha: 0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isAddingExpense.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Add Expense',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ],
            ),
          ),

          // ── List / Empty State ──────────────────────────────────────
          Obx(() {
            if (controller.isLoadingExpenses.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1B2A49),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (controller.expenses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Center(
                  child: Text(
                    'No expenses added yet',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                const Divider(height: 1),
                ...controller.expenses.map(
                  (e) => _ExpenseRow(expense: e),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddExpenseSheet(
      BuildContext context, ActiveTripController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddExpenseSheet(
        onSubmit: (expenseTypeId, amount, notes, receiptPath) {
          controller.addExpense(
            expenseTypeId: expenseTypeId,
            amount: amount,
            notes: notes,
            receiptPath: receiptPath,
          );
        },
      ),
    );
  }
}

// ── Expense Row ───────────────────────────────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  final TripExpenseModel expense;

  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF274472),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.expenseTypeName ?? 'Expense',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                if (expense.notes != null && expense.notes!.isNotEmpty)
                  Text(
                    expense.notes!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (expense.dateDisplay.isNotEmpty)
                  Text(
                    expense.dateDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            expense.amountDisplay,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A49),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Expense Bottom Sheet ──────────────────────────────────────────────────

class _AddExpenseSheet extends StatefulWidget {
  final void Function(
    int expenseTypeId,
    double amount,
    String? notes,
    String? receiptPath,
  ) onSubmit;

  const _AddExpenseSheet({required this.onSubmit});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  static const List<Map<String, dynamic>> _expenseTypes = [
    {'id': 2,  'name': 'Fuel'},
    {'id': 5,  'name': 'Toll / RTO'},
    {'id': 7,  'name': 'Loading Charges'},
    {'id': 8,  'name': 'Unloading Charges'},
    {'id': 12, 'name': 'Other'},
  ];

  int? _selectedTypeId;
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _receiptPath;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded,
                color: Color(0xFF1B2A49)),
            title: Text('Camera', style: GoogleFonts.poppins()),
            onTap: () async {
              Get.back();
              final img = await _picker.pickImage(
                  source: ImageSource.camera, imageQuality: 80);
              if (img != null && mounted) {
                setState(() => _receiptPath = img.path);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: Color(0xFF1B2A49)),
            title: Text('Gallery', style: GoogleFonts.poppins()),
            onTap: () async {
              Get.back();
              final img = await _picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 80);
              if (img != null && mounted) {
                setState(() => _receiptPath = img.path);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submit() {
    if (_selectedTypeId == null) {
      Dialogues.warningToast('Please select an expense type.');
      return;
    }
    final amtStr = _amountCtrl.text.trim();
    if (amtStr.isEmpty) {
      Dialogues.warningToast('Please enter the amount.');
      return;
    }
    final amount = double.tryParse(amtStr);
    if (amount == null || amount <= 0) {
      Dialogues.warningToast('Please enter a valid amount.');
      return;
    }
    final notes = _notesCtrl.text.trim();
    Get.back(); // close sheet
    widget.onSubmit(
      _selectedTypeId!,
      amount,
      notes.isEmpty ? null : notes,
      _receiptPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            28,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Add Expense',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A49),
            ),
          ),
          const SizedBox(height: 20),

          // ── Expense Type ────────────────────────────────────────────
          Text(
            'Expense Type',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedTypeId,
                isExpanded: true,
                hint: Text(
                  'Select type',
                  style: GoogleFonts.poppins(color: Colors.grey.shade400),
                ),
                items: _expenseTypes
                    .map((t) => DropdownMenuItem<int>(
                          value: t['id'] as int,
                          child: Text(t['name'] as String,
                              style: GoogleFonts.poppins()),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTypeId = val),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Amount ─────────────────────────────────────────────────
          Text(
            'Amount (₹)',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1B2A49)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Notes ──────────────────────────────────────────────────
          Text(
            'Notes (Optional)',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add notes...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1B2A49)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Receipt ────────────────────────────────────────────────
          GestureDetector(
            onTap: _pickReceipt,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    _receiptPath != null
                        ? Icons.check_circle_outline_rounded
                        : Icons.attach_file_rounded,
                    color: _receiptPath != null
                        ? const Color(0xFF27AE60)
                        : Colors.grey.shade500,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _receiptPath != null
                        ? 'Receipt attached'
                        : 'Attach receipt (optional)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _receiptPath != null
                          ? const Color(0xFF27AE60)
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (_receiptPath != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _receiptPath = null),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A49),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add Expense',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
