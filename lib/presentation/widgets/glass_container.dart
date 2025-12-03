import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final Gradient? borderGradient;
  final double borderWidth;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.gradient,
    this.border,
    this.borderGradient,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final borderDecoration = borderGradient == null
        ? (border ??
              Border.all(color: Colors.white.withOpacity(0.2), width: 0.5))
        : null;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: borderDecoration,
        gradient: gradient,
      ),
      child: borderGradient != null
          ? CustomPaint(
              painter: _GradientBorderPainter(
                gradient: borderGradient!,
                borderRadius: borderRadius ?? BorderRadius.circular(8),
                strokeWidth: borderWidth,
              ),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            )
          : Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final BorderRadius borderRadius;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final RRect rRect = borderRadius.toRRect(rect);
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
