import 'package:flutter/material.dart';

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Example: slide from right with fade
    const beginOffset = Offset(1.0, 0.0);
    const endOffset = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: beginOffset, end: endOffset)
        .chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
