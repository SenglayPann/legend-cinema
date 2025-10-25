import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legend_cinema/presentation/widgets/loading_overlay.dart';
import 'package:pinput/pinput.dart';
import '../../widgets/app_scaffold.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String? phoneNumber;

  const OtpVerificationScreen({Key? key, this.phoneNumber}) : super(key: key);

  void _onOtpComplete(BuildContext context, String otp) async {
    LoadingOverlay().show(context, message: '');
    try {
      await Future.delayed(const Duration(seconds: 5))
          .timeout(const Duration(seconds: 3));
    } on TimeoutException catch (_) {
      print('⏰ Operation timed out!');
      LoadingOverlay().hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber = phoneNumber ??
        (kDebugMode ? '123456789' : 'Unknown number');

    final defaultPinTheme = PinTheme(
      width: 35,
      height: 45,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 47, 45, 45),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Title
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // 🔹 Subtitle
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Enter verification code we sent to ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      TextSpan(
                        text: '(+855) $displayNumber',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 🔹 OTP Input Field with Pinput
                Center(
                  child: Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: defaultPinTheme,
                    separatorBuilder: (index) => const SizedBox(width: 20),
                    cursor: Container(
                      width: 2,
                      height: 20,
                      color: Colors.red,
                    ),
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) => _onOtpComplete(context, pin),
                    onChanged: (value) {
                      debugPrint('OTP changed: $value');
                    },
                    keyboardType: TextInputType.number, // Only show numeric keyboard
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    ],
                    // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                    // listenForMultipleSmsOnAndroid: true,
                  ),
                ),

                const SizedBox(height: 32),
                // 🔹 Resend text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint('Resend OTP tapped');
                        // TODO: Implement resend OTP
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}