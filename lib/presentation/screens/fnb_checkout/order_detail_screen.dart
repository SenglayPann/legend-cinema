import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/showtime_model.dart';
import '../../state/seat_selection_state.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_alert.dart';
import 'checkout_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final ShowtimeModel showtime;

  const OrderDetailScreen({super.key, required this.showtime});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // 5 minute timer (300 seconds)
  int _remainingSeconds = 300;
  Timer? _timer;

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
        // Session expired - navigate back
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
  Widget build(BuildContext context) {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF090909),
          body: Stack(
            children: [
              // Background Image with Blur (using movie poster)
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
                    // Header with back button and timer
                    _buildHeader(context),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Movie Info + Booking Details Glass Box
                            _buildMovieInfoSection(state),

                            const SizedBox(height: 16),

                            // F&B Items Section (if any)
                            if (state.hasFnbItems) _buildFnbSection(state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Checkout Button at Bottom
              _buildBottomCheckout(context),
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
            'Order Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Session timer (5 minutes)
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

  Widget _buildMovieInfoSection(SeatSelectionState state) {
    // Get seat labels
    final seatLabels = state.selectedSeats.map((s) => s.label).join(', ');

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie poster and title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portrait poster
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: widget.showtime.moviePosterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[800]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 16),
              // Movie title and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.showtime.movieTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.showtime.showDate} • ${widget.showtime.showTime}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.showtime.cinemaName,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const GradientDivider(),
          const SizedBox(height: 16),

          // Booking details rows
          _buildInfoRow(
            'Format',
            widget.showtime.screenType.isNotEmpty
                ? widget.showtime.screenType
                : '2D',
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Hall', 'Hall ${widget.showtime.hallNumber}'),
          const SizedBox(height: 12),
          _buildInfoRow('Seats', seatLabels),
          const SizedBox(height: 12),
          _buildInfoRow('Tickets', '${state.selectedCount}'),
          const SizedBox(height: 12),
          _buildInfoRow('Price', '\$${state.totalPrice.toStringAsFixed(2)}'),

          const SizedBox(height: 16),
          const GradientDivider(),
          const SizedBox(height: 16),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${state.grandTotal.toStringAsFixed(2)}',
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildFnbSection(SeatSelectionState state) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foods & Drinks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // List each FnB item
          ...state.fnbQuantities.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final fnbEntry = entry.value;
            final item = state.fnbItems[fnbEntry.key];
            final quantity = fnbEntry.value;
            final isLast = index == state.fnbQuantities.length - 1;

            if (item == null) return const SizedBox.shrink();

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item image
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[800],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: Icon(Icons.fastfood, color: Colors.white54),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.fastfood, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'x$quantity',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  const GradientDivider(),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }).toList(),

          const SizedBox(height: 16),
          const GradientDivider(),
          const SizedBox(height: 16),

          // FnB subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '\$${state.fnbTotalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(BuildContext context) {
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
            text: 'Checkout',
            onPressed: () {
              final state = context.read<SeatSelectionState>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: state,
                    child: CheckoutScreen(showtime: widget.showtime),
                  ),
                ),
              );
            },
            height: 48,
            borderRadius: 32,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
