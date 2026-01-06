import 'package:flutter/material.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import 'package:legend_cinema/core/constants/app_routes.dart';
import 'package:provider/provider.dart';

class AuthListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const AuthListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Initialize previous state
    final authState = context.read<AuthState>();
    _wasLoggedIn = authState.isLoggedIn;

    // Listen to changes
    authState.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    context.read<AuthState>().removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final authState = context.read<AuthState>();
    final isLoggedIn = authState.isLoggedIn;

    // Detect logout (True -> False transition)
    if (_wasLoggedIn && !isLoggedIn) {
      debugPrint('AuthListener: user logged out, redirecting to login...');
      _handleLogout();
    }

    _wasLoggedIn = isLoggedIn;
  }

  void _handleLogout() {
    // Navigate using the GlobalKey
    final state = widget.navigatorKey.currentState;
    if (state != null) {
      // Clear stack and go to Login
      // But we should check if we are already in splash or non-protected route?
      // Generally if logging out, we want to force Login screen.
      // Exception: If we are in the Splash Screen, we might not want to interrupt?
      // But standard logout happens from UI, so Splash is likely passed.

      state.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
