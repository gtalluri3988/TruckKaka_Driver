import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/localization/translation_keys.dart';
import 'advance_controller.dart';

class AdvanceScreen extends StatelessWidget {
  const AdvanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdvanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A49),
        foregroundColor: Colors.white,
        title: Text(
          TrKeys.advanceRequests.tr,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Request Form ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TrKeys.requestAdvance.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B2A49),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        label: TrKeys.amount.tr,
                        icon: Icons.currency_rupee_rounded,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        final amt = double.tryParse(v) ?? 0;
                        if (amt <= 0) return 'Amount must be greater than 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Reason
                    TextFormField(
                      controller: controller.reasonController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        label: TrKeys.reason.tr,
                        icon: Icons.notes_rounded,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please provide a reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Payment Mode
                    Text(
                      'Payment Mode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                          spacing: 10,
                          children: controller.paymentModes.map((mode) {
                            final isSelected =
                                controller.selectedPaymentMode.value == mode;
                            return ChoiceChip(
                              label: Text(mode),
                              selected: isSelected,
                              selectedColor:
                                  const Color(0xFF1B2A49).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1B2A49)
                                    : Colors.black54,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              onSelected: (_) =>
                                  controller.selectedPaymentMode.value = mode,
                            );
                          }).toList(),
                        )),
                    const SizedBox(height: 20),

                    // Submit button
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submitRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B2A49),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSubmitting.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    TrKeys.submit.tr,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Advance History ────────────────────────────────────────────
            if (controller.tripId != null) ...[
              Text(
                'Request History',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2A49),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1B2A49)),
                  );
                }
                if (controller.advances.isEmpty) {
                  return Center(
                    child: Text(
                      'No advance requests yet.',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  );
                }
                return Column(
                  children: controller.advances.map((adv) {
                    return _AdvanceCard(advance: adv);
                  }).toList(),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF274472)),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF274472), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

class _AdvanceCard extends StatelessWidget {
  final dynamic advance;

  const _AdvanceCard({required this.advance});

  Color get _statusColor {
    switch ((advance.status ?? '').toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              advance.status?.toLowerCase() == 'approved'
                  ? Icons.check_circle_rounded
                  : advance.status?.toLowerCase() == 'rejected'
                      ? Icons.cancel_rounded
                      : Icons.hourglass_top_rounded,
              color: _statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹ ${advance.requestedAmount?.toStringAsFixed(0) ?? '0'}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                if (advance.requestorComments != null)
                  Text(
                    advance.requestorComments!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  advance.status ?? 'Pending',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (advance.approvedAmount != null &&
                  (advance.status ?? '').toLowerCase() == 'approved')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '₹ ${advance.approvedAmount?.toStringAsFixed(0)} paid',
                    style: const TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
