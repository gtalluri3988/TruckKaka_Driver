import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/trip_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/localization/translation_keys.dart';
import 'assigned_trips_controller.dart';

class AssignedTripsScreen extends StatelessWidget {
  const AssignedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignedTripsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A49),
        foregroundColor: Colors.white,
        title: Text(
          TrKeys.assignedTrips.tr,
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
            onPressed: controller.loadTrips,
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
          return _ErrorState(
            message: controller.error.value,
            onRetry: controller.loadTrips,
          );
        }

        if (controller.trips.isEmpty) {
          return _EmptyState(label: TrKeys.noTrips.tr);
        }

        final pending = controller.pendingTrips;
        final accepted = controller.acceptedTrips;

        return RefreshIndicator(
          color: const Color(0xFF1B2A49),
          onRefresh: controller.loadTrips,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, 32 + MediaQuery.of(context).padding.bottom),
            children: [
              // ── Pending Action Required ────────────────────────────────────
              if (pending.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFFE67E22),
                  label: 'Pending Action Required',
                ),
                const SizedBox(height: 12),
                ...pending.map((trip) => _TripCard(
                      trip: trip,
                      onAccept: () =>
                          controller.acceptTrip(trip.tripId ?? 0),
                      onReject: () =>
                          controller.rejectTrip(trip.tripId ?? 0),
                      onViewDetails: () => Get.toNamed(
                        AppRoute.tripDetail,
                        arguments: {'tripId': trip.tripId},
                      ),
                    )),
                const SizedBox(height: 8),
              ],

              // ── Accepted Trips ─────────────────────────────────────────────
              if (accepted.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF27AE60),
                  label: 'Accepted Trips',
                ),
                const SizedBox(height: 12),
                ...accepted.map((trip) => _TripCard(
                      trip: trip,
                      onViewDetails: () => Get.toNamed(
                        AppRoute.tripDetail,
                        arguments: {'tripId': trip.tripId},
                      ),
                    )),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2A49),
          ),
        ),
      ],
    );
  }
}

// ── Trip Card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback onViewDetails;

  const _TripCard({
    required this.trip,
    required this.onViewDetails,
    this.onAccept,
    this.onReject,
  });

  bool get _isPending => onAccept != null && onReject != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Trip ID row + status badge ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.tripCode ?? 'T#${trip.tripId}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2A49),
                  ),
                ),
                const Spacer(),
                if (!_isPending) _StatusBadge(status: trip.status),
              ],
            ),

            // ── Posted timestamp ───────────────────────────────────────────
            if (trip.postedDisplay.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                'Posted: ${trip.postedDisplay}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // ── Pickup ─────────────────────────────────────────────────────
            _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF27AE60),
              label: 'Pickup',
              address: trip.pickupDisplay,
            ),

            const SizedBox(height: 12),

            // ── Drop ───────────────────────────────────────────────────────
            _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: Colors.redAccent,
              label: 'Drop',
              address: trip.dropDisplay,
            ),

            // ── Distance / Duration ────────────────────────────────────────
            if (trip.distanceDurationDisplay.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                trip.distanceDurationDisplay,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // ── Vehicle sub-card ───────────────────────────────────────────
            _SubCard(
              children: [
                _SubCardRow(
                  icon: Icons.local_shipping_outlined,
                  iconColor: const Color(0xFF274472),
                  text: trip.vehicleDisplay,
                ),
                if (trip.startDateTime != null) ...[
                  const SizedBox(height: 8),
                  _SubCardRow(
                    icon: Icons.calendar_today_outlined,
                    iconColor: const Color(0xFF274472),
                    text: trip.startDateTimeDisplay,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // ── Load details sub-card ──────────────────────────────────────
            if (trip.loadDescription != null &&
                trip.loadDescription!.isNotEmpty)
              _SubCard(
                children: [
                  Text(
                    'Load Details',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _loadText(trip),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B2A49),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 14),

            // ── Action buttons ─────────────────────────────────────────────
            if (_isPending)
              _PendingButtons(onReject: onReject!, onAccept: onAccept!)
            else
              _ViewDetailsButton(onTap: onViewDetails),
          ],
        ),
      ),
    );
  }

  String _loadText(TripModel t) {
    final desc = t.loadDescription ?? '';
    if (t.weight != null && t.weight! > 0) {
      return '$desc - ${t.weight!.toStringAsFixed(0)} tons';
    }
    return desc;
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

// ── Sub Card ──────────────────────────────────────────────────────────────────

class _SubCard extends StatelessWidget {
  final List<Widget> children;

  const _SubCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SubCardRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _SubCardRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B2A49),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF27AE60);
      case 'ongoing':
        return const Color(0xFF2980B9);
      case 'completed':
        return const Color(0xFF16A085);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return const Color(0xFFE67E22);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Accept Confirmation Dialog ────────────────────────────────────────────────

void _showAcceptConfirmDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accept Trip?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B2A49),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'By accepting this trip, you consent to location tracking '
              'and commit to completing the delivery.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Cancel
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B2A49),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Accept
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Accept',
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
          ],
        ),
      ),
    ),
  );
}

// ── Pending Action Buttons ────────────────────────────────────────────────────

class _PendingButtons extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const _PendingButtons({required this.onReject, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Reject
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.close_rounded, size: 16,
                color: Colors.redAccent),
            label: Text(
              'Reject',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Accept Trip — shows confirmation dialog first
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _showAcceptConfirmDialog(context, onAccept),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18,
                color: Colors.white),
            label: Text(
              'Accept Trip',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── View Trip Details Button ──────────────────────────────────────────────────

class _ViewDetailsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewDetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B2A49),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'View Trip Details',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A49)),
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
}
