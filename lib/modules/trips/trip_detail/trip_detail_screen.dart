import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/trip_model.dart';
import '../../../utils/localization/translation_keys.dart';
import 'trip_detail_controller.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A49),
        foregroundColor: Colors.white,
        title: Text(
          TrKeys.tripDetails.tr,
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
            onPressed: controller.loadTrip,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B2A49)),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.error.value,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A49),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final trip = controller.trip.value;
        if (trip == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status Card ─────────────────────────────────────────────
              _StatusCard(trip: trip),
              const SizedBox(height: 16),

              // ── Route Card ──────────────────────────────────────────────
              _SectionCard(
                title: 'Route',
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.my_location_rounded,
                      iconColor: Colors.green,
                      label: TrKeys.from.tr,
                      value: trip.startLocation ?? '—',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Divider(height: 1),
                    ),
                    _InfoTile(
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.redAccent,
                      label: TrKeys.to.tr,
                      value: trip.endLocation ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Load Details Card ────────────────────────────────────────
              _SectionCard(
                title: 'Load Details',
                child: Column(
                  children: [
                    if (trip.loadDescription != null)
                      _InfoTile(
                        icon: Icons.inventory_2_rounded,
                        label: TrKeys.load.tr,
                        value: trip.loadDescription!,
                      ),
                    if (trip.weight != null)
                      _InfoTile(
                        icon: Icons.scale_rounded,
                        label: 'Weight',
                        value: '${trip.weight} tons',
                      ),
                    if (trip.distance != null)
                      _InfoTile(
                        icon: Icons.straighten_rounded,
                        label: TrKeys.distance.tr,
                        value: '${trip.distance} km',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Vehicle Card ─────────────────────────────────────────────
              if (trip.vehicleRegNo.isNotEmpty)
                _SectionCard(
                  title: TrKeys.vehicle.tr,
                  child: _InfoTile(
                    icon: Icons.directions_car_rounded,
                    label: 'Reg No',
                    value: trip.vehicleRegNo,
                  ),
                ),

              const SizedBox(height: 12),

              // ── Advance History ─────────────────────────────────────────
              Obx(() {
                final advances = controller.advances;
                final loading = controller.isLoadingAdvances.value;
                if (loading && advances.isEmpty) {
                  return _SectionCard(
                    title: 'Advance Requests',
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1B2A49),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }
                if (advances.isEmpty) {
                  return _SectionCard(
                    title: 'Advance Requests',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Center(
                        child: Text(
                          'No advance requests yet',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return _SectionCard(
                  title: 'Advance Requests',
                  child: Column(
                    children:
                        advances.map((adv) => _AdvanceRow(adv: adv)).toList(),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────────────
              Obx(
                () => _ActionButtons(
                  trip: trip,
                  isLoading: controller.isActionLoading.value,
                  onStart: controller.startTrip,
                  onConfirmPickup: controller.confirmPickup,
                  onComplete: controller.completeTrip,
                  onRequestAdvance: controller.requestAdvance,
                  onGoToActiveTrip: controller.goToActiveTrip,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final dynamic trip;

  const _StatusCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A49),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.tripCode ?? 'Trip #${trip.tripId}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: ${trip.status}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        trip.isCompleted
                            ? Colors.greenAccent
                            : trip.isCancelled
                            ? Colors.redAccent
                            : Colors.amberAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  trip.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B2A49),
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor ?? const Color(0xFF274472)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1B2A49),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final dynamic trip;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback onConfirmPickup;
  final VoidCallback onComplete;
  final VoidCallback onRequestAdvance;
  final VoidCallback onGoToActiveTrip;

  const _ActionButtons({
    required this.trip,
    required this.isLoading,
    required this.onStart,
    required this.onConfirmPickup,
    required this.onComplete,
    required this.onRequestAdvance,
    required this.onGoToActiveTrip,
  });

  @override
  Widget build(BuildContext context) {
    // ── Completed / Cancelled ─────────────────────────────────────────────
    if (trip.isCompleted || trip.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              trip.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: trip.isCompleted ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              trip.isCompleted ? 'Trip Completed' : 'Trip Cancelled',
              style: TextStyle(
                color: trip.isCompleted ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // ── OnGoing — show "View Active Trip" to re-enter the active trip page ──
    if (trip.isOnGoing) {
      return _ActionButton(
        label: 'View Active Trip',
        icon: Icons.navigation_rounded,
        color: const Color(0xFF27AE60),
        isLoading: false,
        onTap: onGoToActiveTrip,
      );
    }

    // ── Accepted — single "Start Trip & Enable Tracking" button ─────────────
    if (trip.isAccepted) {
      return _ActionButton(
        label: 'Start Trip & Enable Tracking',
        icon: Icons.navigation_rounded,
        color: const Color(0xFF27AE60),
        isLoading: isLoading,
        onTap: onStart,
      );
    }

    return const SizedBox.shrink();
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon:
            isLoading
                ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

// ── Advance Row (reused from trip_history_detail_screen pattern) ──────────────

class _AdvanceRow extends StatelessWidget {
  final TripAdvanceModel adv;
  const _AdvanceRow({required this.adv});

  Color get _statusColor {
    switch ((adv.status ?? '').toLowerCase()) {
      case 'approved':
        return const Color(0xFF27AE60);
      case 'rejected':
        return Colors.redAccent;
      case 'paid':
        return Colors.blue;
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
      case 'paid':
        return Icons.payments_rounded;
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
