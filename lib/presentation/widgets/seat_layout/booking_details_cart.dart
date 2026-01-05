import 'package:flutter/material.dart';
import '../../../data/models/fnb_model.dart';
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
  final Map<String, FnbModel> fnbItems;
  final Map<String, int> fnbQuantities;

  const BookingDetailsCart({
    super.key,
    required this.isExpanded,
    required this.bottomBarHeight,
    required this.selectedSeats,
    required this.seatCountByType,
    required this.hall,
    required this.onClose,
    this.fnbItems = const {},
    this.fnbQuantities = const {},
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

              // Tickets section
              const Text(
                'Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (selectedSeats.isEmpty)
                const Text(
                  'No tickets selected',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ..._buildTicketList(),
              const SizedBox(height: 16),
              const GradientDivider(),

              // Foods & Drinks section (only if there are items)
              if (fnbQuantities.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Foods & Drinks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildFnbList(),
                const SizedBox(height: 16),
                const GradientDivider(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFnbList() {
    return fnbQuantities.entries.map((entry) {
      final item = fnbItems[entry.key];
      if (item == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.name} x${entry.value}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  '\$${(item.price * entry.value).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getSeatTypeName(SeatType type) {
    switch (type) {
      case SeatType.regular:
        return 'Standard';
      case SeatType.vip:
        return 'VIP';
      case SeatType.twin:
        return 'Twin';
    }
  }

  double _getSeatPrice(SeatType type) {
    switch (type) {
      case SeatType.regular:
        return hall.seatPrice;
      case SeatType.vip:
        return hall.vipSeatPrice;
      case SeatType.twin:
        return hall.twinSeatPrice;
    }
  }

  List<Widget> _buildTicketList() {
    final List<Widget> items = [];
    final Set<String> processedTwinLabels = {};

    for (final seat in selectedSeats) {
      if (seat.type == SeatType.twin) {
        // Skip if already processed as part of a pair
        if (processedTwinLabels.contains(seat.label)) continue;

        // Find the twin pair (seats with same row, adjacent columns)
        final pairSeat = selectedSeats.where((s) {
          if (s.type != SeatType.twin || s.label == seat.label) return false;
          // Check if same row and adjacent
          return s.row == seat.row &&
              (s.column == seat.column + 1 || s.column == seat.column - 1);
        }).firstOrNull;

        if (pairSeat != null) {
          processedTwinLabels.add(seat.label);
          processedTwinLabels.add(pairSeat.label);
          items.add(
            _buildTicketItem(
              'Twin',
              '${seat.label}, ${pairSeat.label}',
              hall.twinSeatPrice,
            ),
          );
        } else {
          // Single twin seat (edge case)
          items.add(_buildTicketItem('Twin', seat.label, hall.twinSeatPrice));
        }
      } else {
        // Regular or VIP seat
        items.add(
          _buildTicketItem(
            _getSeatTypeName(seat.type),
            seat.label,
            _getSeatPrice(seat.type),
          ),
        );
      }
    }

    return items;
  }

  Widget _buildTicketItem(String typeName, String seatLabel, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seats ($typeName x1)',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                seatLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
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
}
