import 'package:flutter/widgets.dart';
import '../../presentation/screens/splash/splash_screen.dart'; // Create these screens
import '../../presentation/screens/signUp/sign_up_screen.dart';
import '../../presentation/screens/otpVerification/otp_verification.dart';

// 1. Define the model for a single route object
class AppRoute {
  final String name;      // e.g., '/home'
  final Widget component; // The screen widget

  const AppRoute({required this.name, required this.component});
}

// 2. Create the list of route objects
final List<AppRoute> appRoutes = [
  AppRoute(name: '/', component: SplashScreen()),
  AppRoute(name: '/signUp', component: SignUpScreen()),
  AppRoute(name: '/otpVerification', component: OtpVerificationScreen()),
  // Add more routes here...
];