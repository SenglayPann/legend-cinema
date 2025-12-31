import 'package:flutter/material.dart';
import '../../state/seat_selection_state.dart';
import '../gradient_divider.dart';

/// Widget displaying selected seats and seat type pricing
class SelectedSeatsSection extends StatelessWidget {
  final List<Seat> selectedSeats;

  const SelectedSeatsSection({super.key, required this.selectedSeats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Seats title
          const Text(
            'Selected Seats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Selected seats list
          if (selectedSeats.isEmpty)
            const Text(
              'Tap on seats to select',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedSeats.map((seat) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    seat.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          // Divider
          const GradientDivider(),
          const SizedBox(height: 12),
          // Seat types and prices
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSeatTypePrice('Standard', '\$8', Colors.white70),
                _buildSeatTypePrice('VIP', '\$12', Colors.amber),
                _buildSeatTypePrice('Twin', '\$20', Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          const GradientDivider(),
        ],
      ),
    );
  }

  Widget _buildSeatTypePrice(String type, String price, Color color) {
    return Column(
      children: [
        Text(
          type,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          price,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
