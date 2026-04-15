import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/localization/translation_keys.dart';
import 'salary_controller.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalaryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A49),
        foregroundColor: Colors.white,
        title: Text(
          TrKeys.salaryRequests.tr,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: controller.loadSalaryInfo,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B2A49)));
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadSalaryInfo,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A49)),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final tx = controller.transactions.value;
        final status = controller.salaryStatus?.value ?? -1;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status Banner ──────────────────────────────────────────
              _SalaryStatusBanner(status: status),
              const SizedBox(height: 20),

              // ── Salary Breakdown ───────────────────────────────────────
              if (tx != null) ...[
                _SectionTitle('Salary Breakdown'),
                const SizedBox(height: 10),
                _BreakdownCard(
                  rows: [
                    _Row(
                      label: TrKeys.earnedSalary.tr,
                      value:
                          '₹ ${tx.driverEarnedSalary?.toStringAsFixed(2) ?? '0.00'}',
                      highlight: true,
                    ),
                    _Row(
                      label: TrKeys.approvedAmount.tr,
                      value:
                          '₹ ${tx.driverSalaryApprovedAmount?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    _Row(
                      label: 'After Advance Adjustment',
                      value:
                          '₹ ${tx.driverSalaryAfterAdjustment?.toStringAsFixed(2) ?? '0.00'}',
                      highlight: true,
                    ),
                    _Row(
                      label: 'Driver Advance Paid',
                      value:
                          '₹ ${tx.tripDriverAdvance?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    _Row(
                      label: 'Balance Left',
                      value:
                          '₹ ${tx.balanceLeft?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // ── Request Salary Button ──────────────────────────────────
              if (status == -1 || status == 2) // not yet requested or rejected
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.requestSalary,
                      icon: controller.isSubmitting.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.payments_rounded,
                              color: Colors.white),
                      label: Text(
                        TrKeys.requestSalary.tr,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2A49),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _SalaryStatusBanner extends StatelessWidget {
  final int status;

  const _SalaryStatusBanner({required this.status});

  String get _label {
    switch (status) {
      case 0:
        return 'Salary Pending Approval';
      case 1:
        return 'Salary Approved ✓';
      case 2:
        return 'Salary Rejected';
      default:
        return 'No Salary Request Yet';
    }
  }

  Color get _color {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (status) {
      case 0:
        return Icons.hourglass_top_rounded;
      case 1:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 28),
          const SizedBox(width: 12),
          Text(
            _label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B2A49),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final List<_Row> rows;

  const _BreakdownCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: row.highlight
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      row.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: row.highlight
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: row.highlight
                            ? const Color(0xFF1B2A49)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  final bool highlight;

  const _Row({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}
