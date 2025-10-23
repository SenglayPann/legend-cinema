import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color appBarStartColor;
  final Color appBarEndColor;
  final Color backgroundColor;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    Key? key,
    this.title,
    required this.body,
    this.showBackButton = true,
    this.actions,
    this.appBarStartColor = Colors.red,
    this.appBarEndColor = const Color(0xFF090909),
    this.backgroundColor = Colors.black,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title, // ✅ just pass directly
        showBackButton: showBackButton,
        actions: actions,
        startColor: appBarStartColor,
        endColor: appBarEndColor,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
