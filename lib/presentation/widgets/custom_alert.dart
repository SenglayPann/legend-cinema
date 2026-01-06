import 'package:flutter/material.dart';
import 'package:legend_cinema/presentation/widgets/custom_button.dart';

class CustomAlert {
  /// Shows a modal dialog with title, message, and an OK button
  static Future<void> show(
    BuildContext context, {
    String title = 'Alert',
    required String message,
    String okButtonText = 'OK',
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap OK to dismiss
      barrierColor: Colors.black54, // dimmed black background
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 2), // red border
          ),
          backgroundColor: const Color(0xFF090909), // black background
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // title in white
                    ),
                  ),
                if (title.isNotEmpty) const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // message in lighter white
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomButton(
                    text: okButtonText,
                    onPressed: () {
                      Navigator.of(context).pop(); // close modal
                    },
                    backgroundColor: Colors.red, // consistent red button
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog with Title, Message, Confirm and Cancel buttons.
  /// Returns true if Confirmed, false otherwise.
  static Future<bool> showConfirm(
    BuildContext context, {
    String title = 'Confirm',
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 2),
          ),
          backgroundColor: const Color(0xFF090909),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: CustomButton(
                          text: cancelText,
                          onPressed: () => Navigator.of(context).pop(false),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: CustomButton(
                          text: confirmText,
                          onPressed: () => Navigator.of(context).pop(true),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
