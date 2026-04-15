import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/trip_model.dart';
import 'trip_history_detail_controller.dart';

class TripHistoryDetailScreen extends StatelessWidget {
  const TripHistoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripHistoryDetailController());

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
                    trip.tripCode ?? 'T#${trip.tripId}',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: controller.loadAll,
              ),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoadingTrip.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B2A49)));
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  controller.error.value,
                  style:
                      GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadAll,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A49)),
                  child: Text('Retry',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }

        final trip = controller.trip.value;
        if (trip == null) return const SizedBox.shrink();

        return ListView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 32 + MediaQuery.of(context).padding.bottom),
          children: [
            // ── Completed Banner ──────────────────────────────────────
            _CompletedBanner(trip: trip),
            const SizedBox(height: 14),

            // ── Trip Route Card ───────────────────────────────────────
            _TripRouteCard(trip: trip),
            const SizedBox(height: 14),

            // ── Salary Summary Card ───────────────────────────────────
            Obx(() => _SalarySummaryCard(
                  trip: trip,
                  tx: controller.transactions.value,
                  isLoading: controller.isLoadingDetails.value,
                )),
            const SizedBox(height: 14),

            // ── Advance Requests Card ─────────────────────────────────
            Obx(() => _AdvancesCard(
                  advances: controller.advances,
                  isLoading: controller.isLoadingDetails.value,
                )),
            const SizedBox(height: 14),

            // ── Trip Expenses Card ────────────────────────────────────
            Obx(() => _ExpensesCard(
                  expenses: controller.expenses,
                  isLoading: controller.isLoadingDetails.value,
                )),
          ],
        );
      }),
    );
  }
}

// ── Completed Banner ──────────────────────────────────────────────────────────

class _CompletedBanner extends StatelessWidget {
  final TripModel trip;
  const _CompletedBanner({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF27AE60), size: 26),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Completed',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E8449),
                ),
              ),
              Text(
                'Completed on ${trip.completedDateDisplay}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF27AE60),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Trip Route Card ───────────────────────────────────────────────────────────

class _TripRouteCard extends StatelessWidget {
  final TripModel trip;
  const _TripRouteCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.map_outlined,
            title: 'Trip Information',
          ),
          const Divider(height: 1),

          // Pickup
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF27AE60),
              label: 'Pickup',
              address: trip.pickupDisplay,
            ),
          ),

          // Drop
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: Colors.redAccent,
              label: 'Drop',
              address: trip.dropDisplay,
            ),
          ),

          // Distance / Duration
          if (trip.distanceDurationDisplay.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  Icon(Icons.straighten_rounded,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    trip.distanceDurationDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Vehicle + Load
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip.vehicleDisplay.isNotEmpty
                              ? trip.vehicleDisplay
                              : '—',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (trip.loadDescription != null &&
                      trip.loadDescription!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.loadDescription!,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Salary Summary Card ───────────────────────────────────────────────────────

class _SalarySummaryCard extends StatelessWidget {
  final TripModel trip;
  final TripTransactionModel? tx;
  final bool isLoading;

  const _SalarySummaryCard({
    required this.trip,
    required this.tx,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Salary Summary',
          ),
          const Divider(height: 1),

          if (isLoading && tx == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B2A49), strokeWidth: 2),
              ),
            )
          else if (tx == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _BreakdownRow(
                label: 'Earnings',
                value: trip.earningsDisplay,
                highlight: true,
              ),
            )
          else
            Column(
              children: [
                _BreakdownRow(
                  label: 'Earned Salary',
                  value:
                      '₹${tx!.driverEarnedSalary?.toStringAsFixed(0) ?? '0'}',
                  highlight: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _BreakdownRow(
                  label: 'Approved Amount',
                  value:
                      '₹${tx!.driverSalaryApprovedAmount?.toStringAsFixed(0) ?? '0'}',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _BreakdownRow(
                  label: 'Advance Paid',
                  value:
                      '₹${tx!.tripDriverAdvance?.toStringAsFixed(0) ?? '0'}',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _BreakdownRow(
                  label: 'Total Expenses',
                  value:
                      '₹${tx!.totalExpenses?.toStringAsFixed(0) ?? '0'}',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _BreakdownRow(
                  label: 'After Adjustment',
                  value:
                      '₹${tx!.driverSalaryAfterAdjustment?.toStringAsFixed(0) ?? '0'}',
                  highlight: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _BreakdownRow(
                  label: 'Balance Left',
                  value:
                      '₹${tx!.balanceLeft?.toStringAsFixed(0) ?? '0'}',
                ),
                const SizedBox(height: 4),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Advance Requests Card ─────────────────────────────────────────────────────

class _AdvancesCard extends StatelessWidget {
  final RxList<TripAdvanceModel> advances;
  final bool isLoading;

  const _AdvancesCard({required this.advances, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.payments_outlined,
            title: 'Advance Requests',
          ),
          const Divider(height: 1),

          if (isLoading && advances.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B2A49), strokeWidth: 2),
              ),
            )
          else if (advances.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Text(
                  'No advance requests for this trip',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            Column(
              children: advances.map((adv) => _AdvanceRow(adv: adv)).toList(),
            ),
        ],
      ),
    );
  }
}

class _AdvanceRow extends StatelessWidget {
  final TripAdvanceModel adv;
  const _AdvanceRow({required this.adv});

  Color get _statusColor {
    switch ((adv.status ?? '').toLowerCase()) {
      case 'approved':
        return const Color(0xFF27AE60);
      case 'rejected':
        return Colors.redAccent;
      default:
        return const Color(0xFFE67E22);
    }
  }

  IconData get _statusIcon {
    switch ((adv.status ?? '').toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${adv.requestedAmount?.toStringAsFixed(0) ?? '0'}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                if (adv.requestorComments != null &&
                    adv.requestorComments!.isNotEmpty)
                  Text(
                    adv.requestorComments!,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (adv.paymentMode != null)
                  Text(
                    adv.paymentMode!,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                  adv.status ?? 'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
              if ((adv.status ?? '').toLowerCase() == 'approved' &&
                  adv.approvedAmount != null) ...[
                const SizedBox(height: 4),
                Text(
                  '₹${adv.approvedAmount?.toStringAsFixed(0)} paid',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF27AE60)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Trip Expenses Card ────────────────────────────────────────────────────────

class _ExpensesCard extends StatelessWidget {
  final RxList<TripExpenseModel> expenses;
  final bool isLoading;

  const _ExpensesCard({required this.expenses, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // Total
    final total = expenses.fold(0.0, (s, e) => s + (e.amount ?? 0));

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Trip Expenses',
            trailing: expenses.isNotEmpty
                ? Text(
                    'Total: ₹${total.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF274472),
                    ),
                  )
                : null,
          ),
          const Divider(height: 1),

          if (isLoading && expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B2A49), strokeWidth: 2),
              ),
            )
          else if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Text(
                  'No expenses recorded for this trip',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            Column(
              children:
                  expenses.map((exp) => _ExpenseRow(expense: exp)).toList(),
            ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final TripExpenseModel expense;
  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
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
              Icons.receipt_outlined,
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
                        fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    expense.dateDisplay,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade400),
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _CardHeader({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF274472)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A49),
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

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
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
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

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color:
                  highlight ? const Color(0xFF1B2A49) : Colors.grey.shade600,
              fontWeight:
                  highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
                  highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight
                  ? const Color(0xFF1B2A49)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
