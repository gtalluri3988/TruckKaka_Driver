import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../utils/common_widgets/common_button.dart';
import '../../utils/localization/translation_keys.dart';
import 'otp_controller.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF274472), width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.redAccent, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1B2A49),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  TrKeys.verifyNumber.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    '${TrKeys.enterCodeDes.tr} +91 ${controller.mobile.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // OTP Input — no Obx needed; validator is triggered imperatively
                Pinput(
                  controller: controller.otpController,
                  focusNode: controller.otpFocusNode,
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  separatorBuilder: (i) => const SizedBox(width: 10),
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  validator: (v) {
                    final err = controller.otpError.value;
                    return err.isNotEmpty ? err : null;
                  },
                ),

                // Error text — reactive, shown below the PIN field
                Obx(
                  () => controller.otpError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.otpError.value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // Owner-assignment error banner (403 gate)
                Obx(
                  () => controller.isNotAssigned.value
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.redAccent.shade100),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.block_rounded,
                                  color: Colors.redAccent, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You are not assigned to any owner.\nContact admin.',
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

                // Verify button
                Obx(
                  () => CommonButton(
                    text: TrKeys.otpButtonName.tr,
                    color: controller.isLoading.value
                        ? const Color(0xFF274472)
                        : Colors.white,
                    textColor: controller.isLoading.value
                        ? Colors.white
                        : const Color(0xFF274472),
                    isLoading: controller.isLoading.value,
                    onTap: controller.verifyOtp,
                  ),
                ),
                const SizedBox(height: 24),

                // Resend
                Text(
                  TrKeys.didNotReceiveCode.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => GestureDetector(
                        onTap: controller.resendOtp,
                        child: Text(
                          TrKeys.resendCode.tr,
                          style: TextStyle(
                            color: controller.canResend.value
                                ? Colors.greenAccent
                                : Colors.white38,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => controller.canResend.value
                          ? const SizedBox.shrink()
                          : Text(
                              '00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
