import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../utils/localization/translation_keys.dart';
import 'account_controller.dart';

class AccountScreen extends GetView<AccountController> {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B2A49), Color(0xFF274472)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Obx(() => Text(
                            controller.driverName.value,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Driver',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Menu Items ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _MenuSection(
                    title: 'My Activity',
                    items: [
                      _MenuItem(
                        icon: Icons.route_rounded,
                        label: TrKeys.assignedTrips.tr,
                        onTap: () =>
                            Get.toNamed(AppRoute.assignedTrips),
                      ),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        label: TrKeys.tripHistory.tr,
                        onTap: () => Get.toNamed(AppRoute.tripHistory),
                      ),
                      _MenuItem(
                        icon: Icons.request_quote_rounded,
                        label: TrKeys.advanceRequests.tr,
                        onTap: () => Get.toNamed(AppRoute.advance),
                      ),
                      _MenuItem(
                        icon: Icons.payments_rounded,
                        label: TrKeys.salaryRequests.tr,
                        onTap: () => Get.toNamed(AppRoute.salary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: 'Settings',
                    items: [
                      _MenuItem(
                        icon: Icons.language_rounded,
                        label: TrKeys.selectLanguage.tr,
                        onTap: () => Get.toNamed(AppRoute.language),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logout
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: controller.isLoggingOut.value
                            ? null
                            : controller.logout,
                        icon: controller.isLoggingOut.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.redAccent),
                              )
                            : const Icon(Icons.logout_rounded,
                                color: Colors.redAccent),
                        label: Text(
                          TrKeys.logout.tr,
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Section ──────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A49).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, size: 18, color: const Color(0xFF1B2A49)),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B2A49),
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
