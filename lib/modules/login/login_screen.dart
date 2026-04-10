import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/localization/translation_keys.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B2A49), Color(0xFF274472)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ─────────────────────────────────────────────
                    Hero(
                      tag: 'asva_logo',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/images/dashboard/ASVAlogo.png',
                            fit: BoxFit.contain,
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Title ─────────────────────────────────────────────
                    Text(
                      TrKeys.welcome.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TrKeys.loginSubtitle.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Owner-access error ─────────────────────────────────
                    Obx(
                      () => controller.accessError.value.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.redAccent.shade100),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.block_rounded,
                                      color: Colors.redAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      controller.accessError.value,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // ── Phone Input ────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Text(
                            '🇮🇳 +91',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: controller.mobileController,
                              focusNode: controller.mobileFocus,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                hintText: TrKeys.enterMobile.tr,
                                hintStyle: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                counterText: '',
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 10) {
                                  return 'Enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Continue Button ────────────────────────────────────
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF274472),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  TrKeys.continueBtn.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF274472),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Footer ────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          TrKeys.termsConditions.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const Text(
                          '  |  ',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        Text(
                          TrKeys.privacyPolicy.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
