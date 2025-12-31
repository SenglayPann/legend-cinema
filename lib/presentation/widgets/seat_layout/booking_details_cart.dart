import 'package:flutter/material.dart';
import '../../../data/models/hall_model.dart';
import '../../state/seat_selection_state.dart';
import '../glass_container.dart';
import '../gradient_divider.dart';

/// Slide-up cart showing booking details
class BookingDetailsCart extends StatelessWidget {
  final bool isExpanded;
  final double bottomBarHeight;
  final List<Seat> selectedSeats;
  final Map<SeatType, int> seatCountByType;
  final HallModel hall;
  final VoidCallback onClose;

  const BookingDetailsCart({
    super.key,
    required this.isExpanded,
    required this.bottomBarHeight,
    required this.selectedSeats,
    required this.seatCountByType,
    required this.hall,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: isExpanded ? 0 : -MediaQuery.of(context).size.height,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomBarHeight + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GlassContainer(
                    width: 32,
                    height: 32,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(16),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const GradientDivider(),
              const SizedBox(height: 16),

              // Selected seats section
              const Text(
                'Selected Seats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (selectedSeats.isEmpty)
                const Text(
                  'No seats selected',
                  style: TextStyle(color: Colors.white54),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedSeats.map((seat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        seat.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              const GradientDivider(),
              const SizedBox(height: 16),

              // Price breakdown
              const Text(
                'Price Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildPriceRow(
                'Standard',
                seatCountByType[SeatType.regular] ?? 0,
                hall.seatPrice,
              ),
              _buildPriceRow(
                'VIP',
                seatCountByType[SeatType.vip] ?? 0,
                hall.vipSeatPrice,
              ),
              _buildPriceRow(
                'Twin',
                seatCountByType[SeatType.twin] ?? 0,
                hall.twinSeatPrice,
              ),
              const SizedBox(height: 16),
              const GradientDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String type, int count, double price) {
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$type x$count', style: const TextStyle(color: Colors.white70)),
          Text(
            '\$${(count * price).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
