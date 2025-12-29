import 'package:flutter/material.dart';
import '../../state/seat_selection_state.dart';

/// Widget representing a single seat in the layout
class SeatWidget extends StatelessWidget {
  final Seat seat;
  final VoidCallback onTap;
  final double size;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.onTap,
    this.size = 24, // Smaller default size
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: seat.status != SeatStatus.occupied ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        margin: const EdgeInsets.all(2), // Reduced margin
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: _getBorderRadius(),
          border: Border.all(color: _getBorderColor(), width: 1),
          boxShadow: seat.status == SeatStatus.selected
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(child: _getSeatContent()),
      ),
    );
  }

  Widget _getSeatContent() {
    // For occupied seats, show X
    if (seat.status == SeatStatus.occupied) {
      return Icon(Icons.close, size: size * 0.5, color: Colors.grey[600]);
    }

    // For selected seats, show checkmark
    if (seat.status == SeatStatus.selected) {
      return Icon(Icons.check, size: size * 0.55, color: Colors.white);
    }

    // For available seats, show seat number
    return Text(
      '${seat.column}',
      style: TextStyle(
        color: _getTextColor(),
        fontSize: size * 0.45,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getTextColor() {
    switch (seat.type) {
      case SeatType.vip:
        return Colors.amber;
      case SeatType.twin:
        return Colors.purple;
      case SeatType.regular:
        return Colors.white70;
    }
  }

  Color _getBackgroundColor() {
    switch (seat.status) {
      case SeatStatus.selected:
        return const Color(0xFF4CAF50); // Green
      case SeatStatus.occupied:
        return Colors.grey[800]!;
      case SeatStatus.available:
        return _getTypeColor().withOpacity(0.15);
    }
  }

  Color _getBorderColor() {
    switch (seat.status) {
      case SeatStatus.selected:
        return const Color(0xFF4CAF50);
      case SeatStatus.occupied:
        return Colors.grey[700]!;
      case SeatStatus.available:
        return _getTypeColor().withOpacity(0.5);
    }
  }

  Color _getTypeColor() {
    switch (seat.type) {
      case SeatType.vip:
        return Colors.amber;
      case SeatType.twin:
        return Colors.purple;
      case SeatType.regular:
        return Colors.white;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (seat.type) {
      case SeatType.twin:
        return BorderRadius.circular(6);
      case SeatType.vip:
        return BorderRadius.circular(5);
      case SeatType.regular:
        return BorderRadius.circular(3);
    }
  }
}

/// Legend item for seat types
class SeatLegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const SeatLegendItem({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: icon != null ? Icon(icon, size: 10, color: color) : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
