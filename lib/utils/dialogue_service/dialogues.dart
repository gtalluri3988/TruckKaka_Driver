import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

class Dialogues {
  static void warningToast(String content) {
    showToastWidget(
      _ToastWidget(
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.redAccent,
        content: content,
      ),
      position: ToastPosition.top,
      duration: const Duration(seconds: 3),
    );
  }

  static void successToast(String content) {
    showToastWidget(
      _ToastWidget(
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        content: content,
      ),
      position: ToastPosition.top,
      duration: const Duration(seconds: 2),
    );
  }

  static void infoToast(String content) {
    showToastWidget(
      _ToastWidget(
        icon: Icons.info_outline,
        iconColor: const Color(0xFF274472),
        content: content,
      ),
      position: ToastPosition.top,
      duration: const Duration(seconds: 2),
    );
  }

  /// Generic confirm dialog — calls [onConfirm] on OK tap.
  static Future<void> confirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    await showDialog(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2A49),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(cancelText,
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2A49),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmText,
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Confirm dialog that returns true if confirmed, false/null if cancelled.
  static Future<bool?> confirmAsync({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = const Color(0xFF1B2A49),
  }) async {
    return showDialog<bool>(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2A49),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText,
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText,
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ToastWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String content;

  const _ToastWidget({
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
