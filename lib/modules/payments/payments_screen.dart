import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../utils/localization/translation_keys.dart';
import 'payments_controller.dart';

class PaymentsScreen extends GetView<PaymentsController> {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A49),
        foregroundColor: Colors.white,
        title: Text(
          TrKeys.payments.tr,
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
            onPressed: controller.loadPaymentSummary,
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
                  onPressed: controller.loadPaymentSummary,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A49)),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1B2A49),
          onRefresh: controller.loadPaymentSummary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary Cards ─────────────────────────────────────────
                _SummaryCards(controller: controller),
                const SizedBox(height: 24),

                // ── Quick actions ─────────────────────────────────────────
                Text(
                  'Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.request_quote_rounded,
                  label: TrKeys.advanceRequests.tr,
                  subtitle: 'Request advance from owner',
                  onTap: () => Get.toNamed(AppRoute.advance),
                ),
                const SizedBox(height: 10),
                _ActionTile(
                  icon: Icons.payments_rounded,
                  label: TrKeys.salaryRequests.tr,
                  subtitle: 'View and request salary',
                  onTap: () => Get.toNamed(AppRoute.salary),
                ),
                const SizedBox(height: 24),

                // ── Trip earnings list ─────────────────────────────────────
                Text(
                  'Completed Trips',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.completedTrips.isEmpty)
                  Center(
                    child: Text(
                      'No completed trips yet.',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14),
                    ),
                  )
                else
                  ...controller.completedTrips.map((trip) {
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoute.salary,
                        arguments: {'tripId': trip.tripId},
                      ),
                      child: Container(
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2A49)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.route_rounded,
                                color: Color(0xFF1B2A49),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.tripCode ?? 'Trip #${trip.tripId}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1B2A49),
                                    ),
                                  ),
                                  Text(
                                    '${trip.startLocation ?? ''} → ${trip.endLocation ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹ ${trip.salaryAmount?.toStringAsFixed(0) ?? '—'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Summary Cards ─────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  final PaymentsController controller;

  const _SummaryCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            _SummaryCard(
              label: 'Total Earned',
              amount: controller.totalEarned.value,
              icon: Icons.trending_up_rounded,
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Advances',
              amount: controller.totalAdvances.value,
              icon: Icons.north_west_rounded,
              color: Colors.orange,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Balance',
              amount: controller.pendingBalance.value,
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF274472),
            ),
          ],
        ));
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              '₹ ${amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B2A49),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A49).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1B2A49), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2A49),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
