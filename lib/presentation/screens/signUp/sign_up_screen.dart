import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legend_cinema/presentation/screens/otpVerification/otp_verification.dart';
import 'package:legend_cinema/presentation/widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/loading_overlay.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPhoneValid = false;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final valid = digits.length == 9;

    if (valid) {
      FocusScope.of(context).unfocus();
    }

    if (valid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = valid;
      });
    }
     setState(() {});
  }

  void _onGetOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final phoneNumber = '+855${_phoneController.text}';
      debugPrint('Requesting OTP for: $phoneNumber');
      // TODO: Navigate or call API...

      LoadingOverlay().show(context, message: 'Sending OTP...');
      try {
        await Future.delayed(const Duration(seconds: 5))
            .timeout(const Duration(seconds: 3));
      } on TimeoutException catch (_) {
        print('⏰ Operation timed out!');
        LoadingOverlay().hide(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: '${_phoneController.text}',
            ),
          ),
        );

      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6 || digits.length > 9) {
      return 'Enter a valid Cambodian phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return 
      AppScaffold(
      // title: 'sign up',
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 48),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  // const SizedBox(height: 24),
                  const Text(
                    'Enter your phone number and get verification code',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: _validatePhone,
                    prefix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'lib/assets/images/Flag_of_Cambodia.png',
                          width: 28,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+855',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white54),
                        ),
                        const SizedBox(width: 8),
                        const VerticalDivider(width: 1, thickness: 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(bottom: bottomInset),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: CustomButton(
              text: 'Get OTP',
              onPressed: _isPhoneValid ? _onGetOtp : null,
            ),
          ),
        ),
      ),
    );
  }
}
