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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    if (mounted) context.read<AuthState>().setUser(user);

    if (mounted) LoadingOverlay().hide(context);
    // Removed SnackBar as per request

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
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
    CustomAlert.show(
      context,
      title: 'Failed',
      message: e.message ?? 'Failed to sent OTP code.',
    );
  }

  // On Timeout
  void _onTimeout(verificationId) {
    LoadingOverlay().hide(context);

    CustomAlert.show(
      context,
      title: 'Failed',
      message: 'OTP request timed out',
    );
  }

  // Get OTP
  void _onGetOtp() async {
    final phoneNumber = '+855${_phoneController.text.trim()}';

    LoadingOverlay().show(context, message: '');

    try {
      final exists = await _authService.checkUserExists(phoneNumber);
      if (!exists) {
        LoadingOverlay().hide(context);
        if (mounted) {
          CustomAlert.show(
            context,
            title: 'Account Not Found',
            message:
                'This phone number is not registered. Please sign up first.',
          );
        }
        return;
      }

      await _authService.verifyPhone(
        phone: phoneNumber,
        onAutoVerified: (credential) => _onAutoVerified(credential),
        onCodeSent: (verificationId, resendToken) =>
            _onCodeSent(verificationId, resendToken),
        onFailed: (e) => _onFailed(e),
        onTimeout: (verificationId) => _onTimeout(verificationId),
      );
    } catch (e) {
      LoadingOverlay().hide(context);
      if (mounted) {
        CustomAlert.show(
          context,
          title: 'Error',
          message: 'Failed to verify phone number. Please try again.',
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
    return AppScaffold(
      showBackButton: false,
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
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Enter your phone number to login',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const VerticalDivider(width: 1, thickness: 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/signUp'),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

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
              text: 'Login',
              onPressed: _isPhoneValid ? _onGetOtp : null,
            ),
          ),
        ),
      ),
    );
  }
}
