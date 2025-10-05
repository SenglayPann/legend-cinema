import 'package:flutter/widgets.dart';
import '../../presentation/screens/splash/splash_screen.dart'; // Create these screens

// 1. Define the model for a single route object
class AppRoute {
  final String name;      // e.g., '/home'
  final Widget component; // The screen widget

  const AppRoute({required this.name, required this.component});
}

// 2. Create the list of route objects
const List<AppRoute> appRoutes = [
  AppRoute(
    name: '/', 
    component: SplashScreen()
  ),
  // Add more routes here...
];