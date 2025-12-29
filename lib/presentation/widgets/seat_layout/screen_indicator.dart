import 'dart:ui';
import 'package:flutter/material.dart';

/// Visual indicator for the cinema screen at the top of seat layout
class ScreenIndicator extends StatelessWidget {
  const ScreenIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Curved red screen
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          child: CustomPaint(
            size: const Size(double.infinity, 40),
            painter: _ScreenCurvePainter(),
          ),
        ),
        const SizedBox(height: 8),
        // Screen label
        const Text(
          'SCREEN',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ScreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red.shade900,
          Colors.red.shade600,
          Colors.red.shade600,
          Colors.red.shade900,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw curved arc
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.8);

    canvas.drawPath(path, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
