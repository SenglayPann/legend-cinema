import 'package:flutter/material.dart';

class LoadingOverlay {
  static final LoadingOverlay _instance = LoadingOverlay._internal();

  factory LoadingOverlay() => _instance;

  LoadingOverlay._internal();

  bool _isVisible = false;

  /// Show the loading overlay
  void show(BuildContext context, {String? message}) {
    if (_isVisible) return;
    _isVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // disable back button
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hide the loading overlay
  void hide(BuildContext context) {
    if (!_isVisible) return;
    _isVisible = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
