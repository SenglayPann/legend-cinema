import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../presentation/state/auth_state.dart';

/// Service for handling Stripe payments
class StripeService {
  // TODO: Replace with your actual Stripe publishable key
  static const String _publishableKey =
      'pk_test_51QJaeFLg0XW50kg9Uw2B0dB7MD0jCo0yPExBVI3IrfIltFHBE9evbAN9jxwmbjagWWroZWcUrBaRiBzg7H7drbuH008M8407Zc';

  // Singleton instance
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  /// Initialize Stripe - call this in main.dart
  static Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Real Payment Flow
  // ───────────────────────────────────────────────────────────────

  /// 1. Create PaymentIntent on the Backend
  Future<Map<String, dynamic>?> _createPaymentIntent(
    double amount,
    String currency,
    String userId,
  ) async {
    try {
      // Ngrok URL - Works anywhere (Mobile Data, different Wi-Fi)
      const backendUrl =
          'https://sharita-oligopsonistic-unintently.ngrok-free.dev/create-payment-intent';

      // Convert amount to cents (integer)
      final amountInCents = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amountInCents,
          'currency': currency,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Backend error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  /// 2. Initialize Payment Sheet
  Future<bool> _initializePaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Legend Cinema',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Color(0xFF1A1A2E),
              primary: Colors.red,
              componentBackground: Color(0xFF090909),
              componentText: Colors.white,
              secondaryText: Colors.white54,
              placeholderText: Colors.white30,
            ),
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      return false;
    }
  }

  /// 3. Present Payment Sheet
  Future<bool> _presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      debugPrint('Error presenting payment sheet: $e');
      if (e is StripeException) {
        // Handle cancellations or specific errors if needed
        debugPrint('Stripe Error: ${e.error.localizedMessage}');
      }
      return false;
    }
  }

  /// Main method to process payment (Step 1 -> 2 -> 3)
  Future<bool> processPayment({
    required double amount,
    required String currency,
    required BuildContext context,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final userId =
          Provider.of<AuthState>(context, listen: false).currentUser?.id ?? '';
      // Step 1: Create Payment Intent
      final data = await _createPaymentIntent(amount, currency, userId);
      if (data == null || !data.containsKey('clientSecret')) {
        _showErrorDialog(
          context,
          'Failed to create payment intent. Ensure backend is running.',
        );
        return false;
      }
      final clientSecret = data['clientSecret'];

      // Step 2: Initialize Sheet
      final isInitialized = await _initializePaymentSheet(clientSecret);
      if (!isInitialized) {
        _showErrorDialog(context, 'Failed to initialize payment.');
        return false;
      }

      // Step 3: Present Sheet
      final isSuccess = await _presentPaymentSheet();

      if (isSuccess) {
        // 1. Save Notification Locally
        final notificationId = await _saveNotification(userId, items, amount);

        // 2. Notify Backend (with ID)
        if (notificationId != null) {
          await _notifyPaymentSuccess(userId, notificationId);
        }
      }

      return isSuccess;
    } catch (e) {
      _showErrorDialog(context, 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Save notification to Firestore and return the ID
  Future<String?> _saveNotification(
    String userId,
    List<Map<String, dynamic>> items,
    double amount,
  ) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('notifications')
          .add({
            'userId': userId,
            'title': 'Payment Successful',
            'body': _buildNotificationBody(items, amount),
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
            'payload': {'items': items, 'total': amount},
          });
      return docRef.id;
    } catch (e) {
      debugPrint('Error saving notification: $e');
      return null;
    }
  }

  Future<void> _notifyPaymentSuccess(
    String userId,
    String notificationId,
  ) async {
    try {
      const backendUrl =
          'https://sharita-oligopsonistic-unintently.ngrok-free.dev/payment-success';
      await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'notificationId': notificationId}),
      );
    } catch (e) {
      debugPrint('Failed to notify backend of success: $e');
    }
  }

  String _buildNotificationBody(
    List<Map<String, dynamic>> items,
    double amount,
  ) {
    if (items.isEmpty) return 'Payment Successful';
    final buffer = StringBuffer();
    // List first 2 items then "+ X more"
    for (int i = 0; i < items.length; i++) {
      if (i > 0) buffer.write(', ');
      final item = items[i];
      final name = item['name'] ?? 'Item';
      final qty = item['qty'] ?? 1;
      // If name already contains (...) like "Tickets (2)" don't add qty, otherwise add xN
      if (name.toString().contains('(')) {
        buffer.write(name);
      } else {
        buffer.write('$name x$qty');
      }
    }
    return '${buffer.toString()}. Total: \$${amount.toStringAsFixed(2)}';
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Payment Error', style: TextStyle(color: Colors.red)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
