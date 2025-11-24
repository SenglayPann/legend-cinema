import 'package:flutter/widgets.dart';
import 'package:legend_cinema/presentation/screens/more/more_screen.dart';
import 'package:legend_cinema/presentation/screens/offer/offer_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart'; // Create these screens
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/signUp/sign_up_screen.dart';
import '../../presentation/screens/otpVerification/otp_verification.dart';
import '../../presentation/screens/signUpInformation/sign_up_information_screen.dart';
import '../../presentation/screens/example_screen.dart';

// 1. Define the model for a single route object
class AppRoute {
  final String name; // e.g., '/home'
  final Widget component; // The screen widget

  const AppRoute({required this.name, required this.component});
}

// 2. Create the list of route objects
final List<AppRoute> appRoutes = [
  AppRoute(name: '/', component: SplashScreen()),
  AppRoute(name: '/signUp', component: SignUpScreen()),
  // AppRoute(name: '/otpVerification', component: OtpVerificationScreen()),
  AppRoute(name: '/signUpInformation', component: SignUpInformationScreen()),
  AppRoute(name: '/example', component: ExampleScreen()),
  AppRoute(name: '/home', component: HomeScreen()),
  AppRoute(name: '/more', component: MoreScreen()),
  AppRoute(name: '/offer', component: OfferScreen()),
  // Add more routes here...
];
