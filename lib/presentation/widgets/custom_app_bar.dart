import 'dart:ui';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color startColor;
  final Color endColor;
  final List<double> stops;
  final double blurSigmaX;
  final double blurSigmaY;

  const CustomAppBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.actions,
    this.showBackButton = true,
    this.startColor = const Color(0xFF111112), // dark color
    this.endColor = Colors.red, // gradient end color
    this.stops = const [0.0, 1.0],
    this.blurSigmaX = 10.0, // Default blur amount
    this.blurSigmaY = 10.0, // Default blur amount
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Widget? titleTextWidget;
    if (title != null) {
      titleTextWidget = Text(
        title!,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 24.0,
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false, // disables default back button
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: titleTextWidget,
      centerTitle: showBackButton, // Center title only if back button is shown
      titleSpacing: showBackButton ? NavigationToolbar.kMiddleSpacing : 16.0,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: stops,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
