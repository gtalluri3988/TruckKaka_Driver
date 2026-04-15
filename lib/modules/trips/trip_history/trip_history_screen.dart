import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/trip_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/localization/translation_keys.dart';
import 'trip_history_controller.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A49),
        foregroundColor: Colors.white,
        title: Text(
          TrKeys.tripHistory.tr,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: controller.loadHistory,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B2A49)));
        }
        if (controller.error.value.isNotEmpty) {
          return _ErrorState(
              message: controller.error.value,
              onRetry: controller.loadHistory);
        }

        return RefreshIndicator(
          color: const Color(0xFF1B2A49),
          onRefresh: controller.loadHistory,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, 32 + MediaQuery.of(context).padding.bottom),
            children: [
              // ── Stats Row ────────────────────────────────────────────
              _StatsRow(controller: controller),
              const SizedBox(height: 24),

              // ── Section title ────────────────────────────────────────
              Text(
                'Completed Trips',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2A49),
                ),
              ),
              const SizedBox(height: 14),

              // ── Trip list ────────────────────────────────────────────
              if (controller.trips.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Column(
                      children: [
                        Icon(Icons.route_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No completed trips yet',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...controller.trips.map(
                  (trip) => _TripHistoryCard(
                    trip: trip,
                    onTap: () => Get.toNamed(
                      AppRoute.tripHistoryDetail,
                      arguments: {'tripId': trip.tripId},
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

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final TripHistoryController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.route_rounded,
                iconColor: const Color(0xFF2980B9),
                iconBg: const Color(0xFFD6EAF8),
                label: 'Total Trips',
                value: controller.totalTripsCount.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF27AE60),
                iconBg: const Color(0xFFD5F5E3),
                label: 'Total Earned',
                value: controller.totalEarnedDisplay,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFE67E22),
                iconBg: const Color(0xFFFDEBD0),
                label: 'Total Distance',
                value: controller.totalDistanceDisplay,
              ),
            ),
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A49),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Trip History Card ─────────────────────────────────────────────────────────

class _TripHistoryCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const _TripHistoryCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Trip ID + Completed chip ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Trip ID:  ',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: trip.tripCode ?? 'T#${trip.tripId}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B2A49),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Completed chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFF27AE60).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Color(0xFF27AE60),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF27AE60),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ── Completion date ──────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(
                        'Completed: ${trip.completedDateDisplay}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Pickup ────────────────────────────────────────────
                  _LocationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFF27AE60),
                    label: 'Pickup',
                    address: trip.pickupDisplay,
                  ),
                  const SizedBox(height: 8),

                  // ── Drop ─────────────────────────────────────────────
                  _LocationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.redAccent,
                    label: 'Drop',
                    address: trip.dropDisplay,
                  ),

                  // ── Distance / Duration ───────────────────────────────
                  if (trip.distanceDurationDisplay.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      trip.distanceDurationDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // ── Vehicle + Load box ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (trip.loadDescription != null &&
                            trip.loadDescription!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trip.loadDescription!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
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
                ],
              ),
            ),

            // ── Bottom: Earnings | Working Hours ───────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: Row(
                children: [
                  // Earnings
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      color: const Color(0xFFE8F8F0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earnings',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            trip.earningsDisplay,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E8449),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Working Hours
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      color: const Color(0xFFF0F3F8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Working Hours',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            trip.workingHoursDisplay,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B2A49),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
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

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 52, color: Colors.redAccent.shade100),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A49)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
