import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/cinema_model.dart';
// Removed unused fnb_model.dart
import '../../../data/models/fnb_order_model.dart';
import '../../../data/services/fnb_order_service.dart';
import '../../../data/services/stripe_service.dart';
import '../../state/auth_state.dart';
import '../../state/cart_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_alert.dart';

enum PaymentMethod { memberPoint, abaKhqr, card }

class FnbOrderSummaryScreen extends StatefulWidget {
  final CinemaModel cinema;

  const FnbOrderSummaryScreen({super.key, required this.cinema});

  @override
  State<FnbOrderSummaryScreen> createState() => _FnbOrderSummaryScreenState();
}

class _FnbOrderSummaryScreenState extends State<FnbOrderSummaryScreen> {
  // 5 minute timer (300 seconds)
  int _remainingSeconds = 300;
  Timer? _timer;
  bool _isProcessing = false;

  // Default payment method is ABA KHQR
  PaymentMethod _selectedMethod = PaymentMethod.abaKhqr;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        if (mounted) {
          CustomAlert.show(
            context,
            title: 'Session Expired',
            message: 'Your session has expired.',
          ).then((_) {
            if (mounted)
              Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }
      }
    });
  }

  String get _formattedCountdown {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer2<CartState, AuthState>(
      builder: (context, cart, authState, child) {
        // Using CartState for calculations

        return AppScaffold(
          backgroundColor: const Color(0xFF090909),
          showBackButton: false, // Custom back handling in header
          title: 'Order Summary',
          body: Stack(
            children: [
              // Background Image with Blur
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: widget.cinema.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.black),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.black),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Cinema Name Glass Box
                            GlassContainer(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.cinema.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Added Payment Methods
                            const SizedBox(height: 24),
                            // Payment Methods Title
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Payment Method',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Payment Methods List
                            _buildPaymentMethod(
                              PaymentMethod.memberPoint,
                              'Member Point',
                              Icons.card_membership,
                              null, // No discount logic for F&B only currently
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentMethod(
                              PaymentMethod.abaKhqr,
                              'ABA KHQR',
                              Icons.qr_code_2,
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentMethod(
                              PaymentMethod.card,
                              'Debit/Credit Card',
                              Icons.credit_card,
                              null,
                            ),

                            const SizedBox(height: 24),
                            // F&B Items Glass Box (Order Summary)
                            // ... (Rest of existing logic but inside simple Consumer if possible)

                            // Re-implement F&B List here to be clearer
                            _buildOrderSummary(cart),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pay Button at Bottom
              _buildPayButton(context, cart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GlassContainer(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(12),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Title
          const Text(
            'Order Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Session timer
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  color: _remainingSeconds <= 30 ? Colors.red : Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _formattedCountdown,
                  style: TextStyle(
                    color: _remainingSeconds <= 30 ? Colors.red : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    PaymentMethod method,
    String title,
    IconData icon,
    double? discountAmount,
  ) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.red : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.white54,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),

            // Discount info logic can be added here if needed similar to checkout
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartState cart) {
    final cartItems = cart.items.values.toList();
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'F&B Items',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Loop through cart items
          ...cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final cartItem = entry.value;
            final isLast = index == cartItems.length - 1;

            return Column(
              children: [
                // Item Row
                Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(cartItem.item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item Details
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cartItem.item.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "\$${cartItem.item.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Removed Quantity Controls from Summary (Read Only?)
                    // Keeping them if user wants to edit last minute?
                    // Original implementation had controls. Let's keep them.
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => cart.removeItem(cartItem.item),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => cart.addItem(cartItem.item),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Divider (not for last item)
                if (!isLast) ...[
                  const SizedBox(height: 16),
                  const GradientDivider(),
                  const SizedBox(height: 16),
                ],
              ],
            );
          }).toList(),

          const SizedBox(height: 16),
          const GradientDivider(),
          const SizedBox(height: 16),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context, CartState cart) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: CustomButton(
            text: _isProcessing
                ? 'Processing...'
                : 'Pay \$${cart.totalAmount.toStringAsFixed(2)}',
            onPressed: _isProcessing
                ? () {}
                : () => _handlePayment(context, cart),
            height: 48,
            borderRadius: 32,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Implemented logic methods

  Future<void> _handlePayment(BuildContext context, CartState cart) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      bool paymentSuccess = false;

      switch (_selectedMethod) {
        case PaymentMethod.card:
          final stripeService = StripeService();

          // Prepare items for notification from CartState
          final items = cart.items.values.map((cartItem) {
            return {
              'name': cartItem.item.name,
              'qty': cartItem.quantity,
              'price': cartItem.item.price * cartItem.quantity,
            };
          }).toList();

          paymentSuccess = await stripeService.processPayment(
            amount: cart.totalAmount,
            currency: 'USD',
            context: context,
            items: items,
          );
          break;

        case PaymentMethod.abaKhqr:
          // Simulate ABA KHQR payment
          await Future.delayed(const Duration(seconds: 2));
          paymentSuccess = true;
          break;

        case PaymentMethod.memberPoint:
          // Simulate Member Point payment
          await Future.delayed(const Duration(seconds: 2));
          paymentSuccess = true;
          break;
      }

      if (paymentSuccess && mounted) {
        await _createFnbOrder(context, cart);
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(
          context,
          title: 'Payment Failed',
          message: 'Error: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _createFnbOrder(BuildContext context, CartState cart) async {
    final authState = context.read<AuthState>();
    final fnbService = FnbOrderService();

    // Convert Cart Items to FnbOrderItems
    final items = cart.items.values.map((cartItem) {
      return FnbOrderItem(
        fnbId: cartItem.item.id,
        name: cartItem.item.name,
        price: cartItem.item.price,
        imageUrl: cartItem.item.imageUrl,
        quantity: cartItem.quantity,
      );
    }).toList();

    final orderId = await fnbService.createFnbOrder(
      userId: authState.currentUser?.id ?? '',
      cinemaId: widget.cinema.id,
      cinemaName: widget.cinema.name,
      items: items,
      totalAmount: cart.totalAmount,
    );

    if (orderId != null && mounted) {
      // Clear cart
      cart.clearCart();
      _showSuccessDialog(context, orderId);
    } else if (mounted) {
      CustomAlert.show(
        context,
        title: 'Order Failed',
        message: 'Failed to create order. Please contact support.',
      );
    }
  }

  void _showSuccessDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your F&B order has been placed.',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt, color: Colors.white54, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Order ID: ...${orderId.substring(orderId.length - 6)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
