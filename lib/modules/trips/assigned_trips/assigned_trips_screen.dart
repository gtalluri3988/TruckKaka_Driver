import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

        return RefreshIndicator(
          color: const Color(0xFF1B2A49),
          onRefresh: controller.loadTrips,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.trips.length,
            itemBuilder: (context, index) {
              final trip = controller.trips[index];
              return _TripCard(
                trip: trip,
                onAccept: trip.isPendingAcceptance
                    ? () => controller.acceptTrip(trip.tripId ?? 0)
                    : null,
                onReject: trip.isPendingAcceptance
                    ? () => controller.rejectTrip(trip.tripId ?? 0)
                    : null,
                onTap: () => Get.toNamed(
                  AppRoute.tripDetail,
                  arguments: {'tripId': trip.tripId},
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Trip Card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final dynamic trip;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip,
    required this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1B2A49),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    trip.tripCode ?? 'Trip #${trip.tripId}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(status: trip.status),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _RouteRow(
                    from: trip.startLocation ?? '—',
                    to: trip.endLocation ?? '—',
                  ),
                  if (trip.loadDescription != null) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Load',
                      value: trip.loadDescription!,
                    ),
                  ],
                  if (trip.vehicleRegNo.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.directions_car_outlined,
                      label: 'Vehicle',
                      value: trip.vehicleRegNo,
                    ),
                  ],

                  // Accept/Reject buttons (only for pending)
                  if (onAccept != null || onReject != null) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (onReject != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side:
                                    const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                        if (onReject != null && onAccept != null)
                          const SizedBox(width: 10),
                        if (onAccept != null)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B2A49),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Accept',
                                  style: TextStyle(color: Colors.white)),
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
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String from;
  final String to;

  const _RouteRow({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 10, color: Color(0xFF274472)),
            Container(
              width: 2,
              height: 30,
              color: Colors.grey.shade300,
            ),
            const Icon(Icons.location_on_rounded,
                size: 14, color: Colors.redAccent),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A49),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                to,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

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
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A49)),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
