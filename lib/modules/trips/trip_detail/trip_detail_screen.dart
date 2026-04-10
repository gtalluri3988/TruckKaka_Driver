import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
                Text(controller.error.value,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadTrip,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A49)),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final trip = controller.trip.value;
        if (trip == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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

              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────────────
              Obx(() => _ActionButtons(
                    trip: trip,
                    isLoading: controller.isActionLoading.value,
                    onStart: controller.startTrip,
                    onConfirmPickup: controller.confirmPickup,
                    onComplete: controller.completeTrip,
                    onRequestAdvance: controller.requestAdvance,
                  )),
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
                  fontSize: 16,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    color: trip.isCompleted
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
                      fontWeight: FontWeight.w600),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1B2A49),
                      fontWeight: FontWeight.w600)),
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

  const _ActionButtons({
    required this.trip,
    required this.isLoading,
    required this.onStart,
    required this.onConfirmPickup,
    required this.onComplete,
    required this.onRequestAdvance,
  });

  @override
  Widget build(BuildContext context) {
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

    return Column(
      children: [
        // Advance request — always available during active trip
        if (trip.isAccepted || trip.isOnGoing)
          _ActionButton(
            label: TrKeys.requestAdvance.tr,
            icon: Icons.request_quote_rounded,
            color: const Color(0xFF2E6B9E),
            isLoading: false,
            onTap: onRequestAdvance,
          ),

        const SizedBox(height: 10),

        // Start Trip — only if accepted but not yet started
        if (trip.isAccepted && !trip.isOnGoing)
          _ActionButton(
            label: TrKeys.startTrip.tr,
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF274472),
            isLoading: isLoading,
            onTap: onStart,
          ),

        // Confirm Pickup — available after starting
        if (trip.isOnGoing)
          _ActionButton(
            label: TrKeys.confirmPickup.tr,
            icon: Icons.check_rounded,
            color: Colors.green.shade700,
            isLoading: isLoading,
            onTap: onConfirmPickup,
          ),

        // Complete Trip — available after pickup confirmed
        if (trip.isOnGoing)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _ActionButton(
              label: TrKeys.completeTrip.tr,
              icon: Icons.flag_rounded,
              color: const Color(0xFF1B2A49),
              isLoading: isLoading,
              onTap: onComplete,
            ),
          ),
      ],
    );
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
        icon: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
      ),
    );
  }
}
