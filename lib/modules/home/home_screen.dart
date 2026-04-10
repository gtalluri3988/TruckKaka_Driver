import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../utils/localization/translation_keys.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: const Color(0xFF1B2A49),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B2A49), Color(0xFF274472)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_shipping_rounded,
                                color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'TruckKaka Driver',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                              'Hi, ${controller.driverName.value} 👋',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: controller.refreshActiveTrip,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Active Trip Banner ────────────────────────────────────
                  Obx(() {
                    if (controller.isCheckingTrip.value) {
                      return _loadingCard();
                    }
                    final trip = controller.activeTrip.value;
                    if (trip != null && trip.isActive) {
                      return _ActiveTripCard(trip: trip);
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 24),

                  // ── Quick Menu ────────────────────────────────────────────
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2A49),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: [
                      _MenuCard(
                        icon: Icons.route_rounded,
                        label: TrKeys.assignedTrips.tr,
                        color: const Color(0xFF1B2A49),
                        onTap: () => Get.toNamed(AppRoute.assignedTrips),
                      ),
                      _MenuCard(
                        icon: Icons.history_rounded,
                        label: TrKeys.tripHistory.tr,
                        color: const Color(0xFF274472),
                        onTap: () => Get.toNamed(AppRoute.tripHistory),
                      ),
                      _MenuCard(
                        icon: Icons.request_quote_rounded,
                        label: TrKeys.advanceRequests.tr,
                        color: const Color(0xFF2E6B9E),
                        onTap: () => Get.toNamed(AppRoute.advance),
                      ),
                      _MenuCard(
                        icon: Icons.payments_rounded,
                        label: TrKeys.salaryRequests.tr,
                        color: const Color(0xFF1A5276),
                        onTap: () => Get.toNamed(AppRoute.salary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1B2A49),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ── Active Trip Banner Card ───────────────────────────────────────────────────

class _ActiveTripCard extends StatelessWidget {
  final dynamic trip;

  const _ActiveTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoute.tripDetail,
        arguments: {'tripId': trip.tripId},
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B2A49), Color(0xFF274472)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2A49).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trip.status,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white70, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.my_location_rounded,
                    color: Colors.greenAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.startLocation ?? '—',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.redAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.endLocation ?? '—',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (trip.tripCode != null) ...[
              const SizedBox(height: 10),
              Text(
                'Trip: ${trip.tripCode}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B2A49),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
