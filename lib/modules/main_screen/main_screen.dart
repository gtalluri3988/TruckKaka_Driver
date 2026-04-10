import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/localization/translation_keys.dart';
import 'main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: controller.pages[controller.selectedIndex.value],
        bottomNavigationBar: _DriverBottomNav(controller: controller),
      );
    });
  }
}

class _DriverBottomNav extends StatelessWidget {
  final MainController controller;

  const _DriverBottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: TrKeys.home.tr,
                index: 0,
                currentIndex: controller.selectedIndex.value,
                onTap: () => controller.selectTab(0),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: TrKeys.account.tr,
                index: 1,
                currentIndex: controller.selectedIndex.value,
                onTap: () => controller.selectTab(1),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: TrKeys.payments.tr,
                index: 2,
                currentIndex: controller.selectedIndex.value,
                onTap: () => controller.selectTab(2),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B2A49).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? const Color(0xFF1B2A49)
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF1B2A49)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
