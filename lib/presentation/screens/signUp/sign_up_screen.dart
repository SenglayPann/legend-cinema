import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legend_cinema/data/services/auth_services.dart';
import 'package:legend_cinema/presentation/screens/otpVerification/otp_verification.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import 'package:legend_cinema/presentation/widgets/custom_alert.dart';
import 'package:legend_cinema/presentation/widgets/custom_button.dart';
import 'package:provider/provider.dart';
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
  final _authService = AuthServices();

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

  // On auto verified
  void _onAutoVerified(credential) async {
    // Android auto-verification — directly sign in
    final userCredential = await _authService.signInWithSmsCode(
      verificationId: credential.verificationId ?? '',
      smsCode: credential.smsCode ?? '',
    );

    final user = await _authService.postSignIn(userCredential);
    context.read<AuthState>().setUser(user); 

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    LoadingOverlay().hide(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification successful!')),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (isNewUser) {
      Navigator.pushNamed(
        context,
        '/signUpInformation',
        arguments: {
          'phoneNumber': _phoneController.text.trim(),
          'userId': user?.id ?? userCredential.user?.uid ?? '',
        },
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/example', (_) => false);
    }
  }

  // on code sent
  void _onCodeSent(verificationId, resendToken) {

    LoadingOverlay().hide(context);

    // Navigate to OTP verification screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phoneNumber: _phoneController.text,
          verificationId: verificationId,
          resendToken: resendToken,
        ),
      ),
    );
  }

  // On failed
  void _onFailed(e) {
    LoadingOverlay().hide(context);
    CustomAlert.show(context, title: 'Failed', message: e.message ?? 'Failed to sent OTP code.');
  }

  // On Timeout
  void _onTimeout(verificationId) {
    LoadingOverlay().hide(context);
    
    CustomAlert.show(context, title: 'Failed', message: 'OTP request timed out');
  }

  // Get OTP
  void _onGetOtp() async {
    final phoneNumber = '+855${_phoneController.text.trim()}';

    LoadingOverlay().show(context, message: '');
    

    await _authService.verifyPhone(
      phone: phoneNumber,
      onAutoVerified: (credential) => _onAutoVerified(credential),
      onCodeSent: (verificationId, resendToken) => _onCodeSent(verificationId, resendToken),
      onFailed: (e) => _onFailed(e),
      onTimeout: (verificationId) => _onTimeout(verificationId),
    );
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
