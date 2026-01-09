import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class DashedBorder extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedBorder(
      {this.color = AppColors.blackColor,
      this.dashWidth = 5.0,
      this.dashSpace = 3.0,
      this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var x = 0.0, y = 0.0;
    final space = dashWidth + dashSpace;

    // Top
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += space;
    }

    x = size.width;
    // Right
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashWidth), paint);
      y += space;
    }

    y = size.height;
    // Bottom
    while (x > 0) {
      canvas.drawLine(Offset(x, y), Offset(x - dashWidth, y), paint);
      x -= space;
    }

    x = 0.0;
    // Left
    while (y > 0) {
      canvas.drawLine(Offset(x, y), Offset(x, y - dashWidth), paint);
      y -= space;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final double borderRadius;
  final Color color;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.borderRadius = 0.0,
    this.strokeWidth = 1.0,
    this.color = AppColors.blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius)),
      child: CustomPaint(
        painter: DashedBorder(
          color: color,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
          strokeWidth: strokeWidth,
        ),
        child: child,
      ),
    );
  }
}
