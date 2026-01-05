import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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

  /// Create a payment sheet and process payment
  /// In production, the paymentIntentClientSecret should come from your backend
  Future<bool> processPayment({
    required double amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      // In production, you would call your backend to create a PaymentIntent
      // and get the client secret. For now, we'll show the demo flow.

      // This is a placeholder - in real implementation:
      // 1. Call your backend API to create PaymentIntent
      // 2. Get the client_secret from the response
      // 3. Initialize the payment sheet with that secret

      // For demo purposes, show a simulated card input
      await _showDemoPaymentSheet(context, amount, currency);

      return true;
    } catch (e) {
      debugPrint('Stripe payment error: $e');
      if (e is StripeException) {
        _showErrorDialog(context, e.error.localizedMessage ?? 'Payment failed');
      } else {
        _showErrorDialog(context, 'An unexpected error occurred');
      }
      return false;
    }
  }

  /// Demo payment sheet (replace with real implementation)
  Future<void> _showDemoPaymentSheet(
    BuildContext context,
    double amount,
    String currency,
  ) async {
    // Show a demo dialog since we don't have a real backend
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Card Payment',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      labelStyle: TextStyle(color: Colors.white54),
                      hintText: '4242 4242 4242 4242',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.credit_card,
                        color: Colors.white54,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'MM/YY',
                            labelStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'CVC',
                            labelStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${amount.toStringAsFixed(2)} $currency',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) {
      throw Exception('Payment cancelled');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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

  /// Initialize Stripe Payment Sheet with real PaymentIntent
  /// Use this when you have a backend
  Future<bool> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: merchantDisplayName,
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
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

      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      debugPrint('Stripe payment sheet error: $e');
      return false;
    }
  }
}
