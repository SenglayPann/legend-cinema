import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:legend_cinema/presentation/widgets/custom_alert.dart';
import 'package:legend_cinema/presentation/widgets/loading_overlay.dart';
import '../../../data/services/auth_services.dart';
import 'package:pinput/pinput.dart';
import '../../widgets/app_scaffold.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthServices _authServices = AuthServices();
  late String _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  bool _canResend = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  final _authService = AuthServices();

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onAutoVerified(credential) async {
    // Android auto-verification — directly sign in
    final userCredential = await _authService.signInWithSmsCode(
      verificationId: credential.verificationId ?? '',
      smsCode: credential.smsCode ?? '',
    );

    final user = await _authService.postSignIn(userCredential);
    context.read<AuthState>().setUser(user);

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (mounted) LoadingOverlay().hide(context);

    if (isNewUser) {
      Navigator.pushNamed(
        context,
        '/signUpInformation',
        arguments: {
          'phoneNumber': widget.phoneNumber,
          'userId': user.id ?? userCredential.user?.uid ?? '',
        },
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
    }
  }

  void _onCodeSent(verificationId, resendToken) {
    if (mounted) {
      setState(() {
        // Update new verification ID + resend token
        _verificationId = verificationId;
        _resendToken = resendToken;
      });
      // Removed success snackbar as per request
      _startResendTimer();
    }
  }

  void _onFailed(e) {
    CustomAlert.show(
      context,
      title: 'Failed',
      message: 'Failed to resend: ${e.message}',
    );
  }

  void _onTimeout(verificationId) {
    debugPrint('Resend timeout: $verificationId');
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);
    LoadingOverlay().show(context, message: '');

    try {
      await _authServices.verifyPhone(
        phone: widget.phoneNumber,
        onAutoVerified: _onAutoVerified,
        onCodeSent: _onCodeSent,
        onFailed: _onFailed,
        onTimeout: _onTimeout,
        forceResendingToken: _resendToken,
      );
    } finally {
      if (mounted) {
        LoadingOverlay().hide(context);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onOtpComplete(BuildContext context, String otp) async {
    // ...
    try {
      final userCred = await _authServices.signInWithSmsCode(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Call the improved postSignIn, which returns a complete user model
      final user = await _authServices.postSignIn(userCred);

      // Save the user and update the shared AuthState provided at app root
      // Use the Provider instance so the rest of the app (ExampleScreen etc.) sees the change
      context.read<AuthState>().setUser(
        user,
      ); // setUser calls saveUserToStorage automatically

      if (!mounted) return;

      LoadingOverlay().hide(context);

      await Future.delayed(const Duration(milliseconds: 300));

      final isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        Navigator.pushReplacementNamed(context, '/signUpInformation');
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      LoadingOverlay().hide(context);
      CustomAlert.show(
        context,
        title: 'Failed',
        message: e.message?.isNotEmpty == true
            ? 'Verification failed: ${e.message}'
            : 'Incorrect verification code',
      );
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay().hide(context);
      CustomAlert.show(context, message: 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber = widget.phoneNumber.isNotEmpty
        ? widget.phoneNumber
        : (kDebugMode ? '123456789' : 'Unknown number');

    final defaultPinTheme = PinTheme(
      width: 45,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 47, 45, 45),
        borderRadius: BorderRadius.circular(10),
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
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Enter the 6-digit code we sent to ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      TextSpan(
                        text: '(+855) $displayNumber',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    separatorBuilder: (index) => const SizedBox(width: 12),
                    cursor: Container(width: 2, height: 20, color: Colors.red),
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) => _onOtpComplete(context, pin),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: _canResend
                          ? () {
                              debugPrint('Resend OTP tapped');
                              // TODO: Call your resend OTP logic
                              _resendOtp();
                            }
                          : null,
                      child: Text(
                        _canResend
                            ? 'Resend'
                            : 'Resend in $_secondsRemaining s',
                        style: TextStyle(
                          color: _canResend ? Colors.red : Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
