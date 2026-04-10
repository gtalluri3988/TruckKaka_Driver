import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonButton extends StatelessWidget {
  final Color? color;
  final Color? textColor;
  final Color? prefixColor;
  final String text;
  final VoidCallback onTap;
  final bool needBorder;
  final Color? borderColor;
  final bool isLoading;
  final IconData? suffixIcon;
  final IconData? prefixIcon;

  const CommonButton({
    super.key,
    this.color,
    required this.text,
    required this.onTap,
    this.textColor,
    this.needBorder = false,
    this.borderColor,
    this.isLoading = false,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color ?? Colors.white,
          border: Border.all(
            color: needBorder
                ? (borderColor ?? Colors.white)
                : Colors.transparent,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null)
                      Icon(
                        prefixIcon,
                        color: prefixColor ?? const Color(0xFF274472),
                        size: 18,
                      ).paddingOnly(right: 8),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: textColor ?? const Color(0xFF274472),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (suffixIcon != null)
                      Icon(
                        suffixIcon,
                        color: textColor ?? const Color(0xFF274472),
                        size: 18,
                      ).paddingOnly(left: 8),
                  ],
                ),
        ),
      ),
    );
  }
}
