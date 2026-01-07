import 'package:flutter/material.dart';
import 'package:legend_cinema/core/constants/app_routes.dart';
import 'package:legend_cinema/presentation/screens/cinema/cinema_screen.dart';
import 'package:legend_cinema/presentation/screens/fnb/fnb_screen.dart';
import 'package:legend_cinema/presentation/screens/more/more_screen.dart';
import 'package:legend_cinema/presentation/screens/notification/notification_list_screen.dart';
import 'package:legend_cinema/presentation/screens/offer/offer_screen.dart';
import 'package:legend_cinema/presentation/screens/more/edit_profile_screen.dart';
import 'package:legend_cinema/presentation/screens/login/login_screen.dart';
import 'package:legend_cinema/presentation/screens/otpVerification/otp_verification.dart';
import 'package:legend_cinema/presentation/screens/splash/splash_screen.dart';
import 'package:legend_cinema/presentation/screens/home/home_screen.dart';
import 'package:legend_cinema/presentation/screens/signUp/sign_up_screen.dart';
import 'package:legend_cinema/presentation/screens/signUpInformation/sign_up_information_screen.dart';
import 'package:legend_cinema/presentation/screens/example_screen.dart';
import 'package:legend_cinema/presentation/screens/main/main_screen.dart';
import 'package:legend_cinema/presentation/screens/fnb_checkout/checkout_screen.dart';
import 'package:legend_cinema/presentation/screens/fnb_checkout/order_detail_screen.dart';
import 'package:legend_cinema/data/models/showtime_model.dart';
import 'package:legend_cinema/presentation/screens/more/about_us_screen.dart';
import 'package:legend_cinema/presentation/screens/more/privacy_policy_screen.dart';
import 'package:legend_cinema/presentation/screens/more/terms_and_conditions_screen.dart';
import 'package:legend_cinema/presentation/screens/notification/notification_detail_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case AppRoutes.signUpInformation:
        // Handle arguments if needed, but currently SignUpInformationScreen accepts constructor args
        // that are often passed via arguments in pushNamed
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SignUpInformationScreen(
            phoneNumber: args?['phoneNumber'],
            userId: args?['userId'],
          ),
        );

      case AppRoutes.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            verificationId: args?['verificationId'] ?? '',
            resendToken: args?['resendToken'],
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.more:
        return MaterialPageRoute(builder: (_) => const MoreScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.cinema:
        return MaterialPageRoute(builder: (_) => const CinemaScreen());

      case AppRoutes.offer:
        return MaterialPageRoute(builder: (_) => const OfferScreen());

      case AppRoutes.fnb:
        return MaterialPageRoute(builder: (_) => const FnBScreen());

      case AppRoutes.checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('showtime')) {
          return MaterialPageRoute(
            builder: (_) =>
                CheckoutScreen(showtime: args['showtime'] as ShowtimeModel),
          );
        }
        return _errorRoute(settings);

      case AppRoutes.orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('showtime')) {
          return MaterialPageRoute(
            builder: (_) =>
                OrderDetailScreen(showtime: args['showtime'] as ShowtimeModel),
          );
        }
        return _errorRoute(settings);

      case AppRoutes.example:
        return MaterialPageRoute(builder: (_) => const ExampleScreen());

      case AppRoutes.aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());

      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      case AppRoutes.termsConditions:
        return MaterialPageRoute(
          builder: (_) => const TermsAndConditionsScreen(),
        );

      case AppRoutes.notificationDetail:
        final args = settings.arguments as String?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => NotificationDetailScreen(notificationId: args),
          );
        }
        return _errorRoute(settings);

      case AppRoutes.notificationList:
        return MaterialPageRoute(
          builder: (_) => const NotificationListScreen(),
        );

      default:
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
