import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/showtime_model.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/services/stripe_service.dart';
import '../../state/auth_state.dart';
import '../../state/seat_selection_state.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_alert.dart';

enum PaymentMethod { memberPoint, abaKhqr, card }

class CheckoutScreen extends StatefulWidget {
  final ShowtimeModel showtime;

  const CheckoutScreen({super.key, required this.showtime});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // 5 minute timer (300 seconds)
  int _remainingSeconds = 300;
  Timer? _timer;
  bool _isProcessing = false;

  // Default payment method is Card
  PaymentMethod _selectedMethod = PaymentMethod.card;

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
            title: 'session_expired'.tr(),
            message: 'session_expired_msg'.tr(),
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
  Widget build(BuildContext context) {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        final discountAmount = state.grandTotal * 0.1;

        return Scaffold(
          backgroundColor: const Color(0xFF090909),
          body: Stack(
            children: [
              // Background Image with Blur
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: widget.showtime.moviePosterUrl,
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

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Payment Methods Title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'payment_method'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Payment Methods List
                            /*
                            _buildPaymentMethod(
                              PaymentMethod.memberPoint,
                              'Member Point',
                              Icons.card_membership,
                              discountAmount,
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentMethod(
                              PaymentMethod.abaKhqr,
                              'ABA KHQR',
                              Icons.qr_code_2,
                              null,
                            ),
                            const SizedBox(height: 12),
                            */
                            _buildPaymentMethod(
                              PaymentMethod.card,
                              'debit_credit_card'.tr(),
                              Icons.credit_card,
                              null,
                            ),

                            const SizedBox(height: 24),

                            // Order Summary
                            _buildOrderSummary(state, discountAmount),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pay Button at Bottom
              _buildPayButton(context, state, discountAmount),
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
          Text(
            'checkout'.tr(),
            style: const TextStyle(
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

            // Member Point discount info
            if (method == PaymentMethod.memberPoint) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'discount_10_percent'.tr(),
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'save_amount'.tr(
                            args: [
                              '\$${discountAmount?.toStringAsFixed(2) ?? '0.00'}',
                            ],
                          ),
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'member_discount_desc'.tr(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(SeatSelectionState state, double discountAmount) {
    final isMemberPoint = _selectedMethod == PaymentMethod.memberPoint;
    final finalTotal = isMemberPoint
        ? state.grandTotal - discountAmount
        : state.grandTotal;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_summary'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tickets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'tickets_count'.tr(args: ['${state.selectedCount}']),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              Text(
                '\$${state.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),

          // FnB (if any)
          if (state.hasFnbItems) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'fnb_count'.tr(args: ['${state.fnbTotalItems}']),
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                Text(
                  '\$${state.fnbTotalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],

          // Discount (if member point selected)
          if (isMemberPoint) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'member_discount_label'.tr(),
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
                Text(
                  '-\$${discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const GradientDivider(),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${finalTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(
    BuildContext context,
    SeatSelectionState state,
    double discountAmount,
  ) {
    final isMemberPoint = _selectedMethod == PaymentMethod.memberPoint;
    final finalTotal = isMemberPoint
        ? state.grandTotal - discountAmount
        : state.grandTotal;

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
                ? 'processing'.tr()
                : 'pay_amount'.tr(args: ['\$${finalTotal.toStringAsFixed(2)}']),
            onPressed: _isProcessing
                ? () {}
                : () => _handlePayment(context, finalTotal),
            height: 48,
            borderRadius: 32,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context, double amount) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      bool paymentSuccess = false;
      String paymentMethodName = '';

      switch (_selectedMethod) {
        case PaymentMethod.card:
          paymentMethodName = 'card';
          final stripeService = StripeService();
          final state = context.read<SeatSelectionState>();

          // Prepare items for notification
          final items = <Map<String, dynamic>>[];
          // Tickets
          if (state.selectedCount > 0) {
            items.add({
              'name': 'tickets_count'.tr(args: ['${state.selectedCount}']),
              'qty': state.selectedCount,
              'price': state.totalPrice,
            });
          }
          // F&B
          for (final item in state.fnbItems.values) {
            final qty = state.fnbQuantities[item.id] ?? 0;
            if (qty > 0) {
              items.add({
                'name': item.name,
                'qty': qty,
                'price': item.price * qty,
              });
            }
          }

          paymentSuccess = await stripeService.processPayment(
            amount: amount,
            currency: 'USD',
            context: context,
            items: items,
          );
          break;

        case PaymentMethod.abaKhqr:
          paymentMethodName = 'aba_khqr';
          // Simulate ABA KHQR payment
          await Future.delayed(const Duration(seconds: 2));
          paymentSuccess = true;
          break;

        case PaymentMethod.memberPoint:
          paymentMethodName = 'member_point';
          // Simulate Member Point payment
          await Future.delayed(const Duration(seconds: 2));
          paymentSuccess = true;
          break;
      }

      if (paymentSuccess && mounted) {
        // Create booking after successful payment
        await _createBooking(context, paymentMethodName);
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(
          context,
          title: 'payment_failed'.tr(),
          message: '${'error'.tr()}: $e',
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

  Future<void> _createBooking(
    BuildContext context,
    String paymentMethod,
  ) async {
    final state = context.read<SeatSelectionState>();
    final authState = context.read<AuthState>();
    final bookingService = BookingService();

    // Get seat prices from hall
    final seatPrices = <String, int>{
      'regular': state.hall.seatPrice.toInt(),
      'vip': state.hall.vipSeatPrice.toInt(),
      'twin': state.hall.twinSeatPrice.toInt(),
    };

    final result = await bookingService.createBookingWithFnb(
      userId: authState.currentUser?.id ?? '',
      userEmail: authState.currentUser?.email ?? '',
      userName: authState.currentUser?.userName ?? 'Guest',
      showtime: widget.showtime,
      selectedSeats: state.selectedSeats,
      seatPrices: seatPrices,
      seatsTotal: state.totalPrice,
      fnbItems: state.fnbItems,
      fnbQuantities: state.fnbQuantities,
      fnbTotal: state.fnbTotalPrice,
      paymentMethod: paymentMethod,
      paymentStatus: 'paid',
    );

    if (result.success && mounted) {
      _showSuccessDialog(context, result.bookingCode ?? 'N/A');
    } else if (mounted) {
      CustomAlert.show(
        context,
        title: 'Booking Failed', // Need key if not already
        message: result.error ?? 'Unknown error',
      );
    }
  }

  void _showSuccessDialog(BuildContext context, String bookingCode) {
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
            Text(
              'payment_success'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'booking_confirmed'.tr(),
              style: const TextStyle(color: Colors.white54),
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
                  const Icon(
                    Icons.confirmation_number,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bookingCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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
            child: Text(
              'done'.tr(),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
