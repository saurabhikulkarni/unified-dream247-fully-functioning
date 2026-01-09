import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class GstDetailContainer extends StatelessWidget {
  final Widget child;
  final double arrowSize;
  final Color backgroundColor;

  const GstDetailContainer({
    super.key,
    required this.child,
    this.arrowSize = 12.0,
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.only(top: arrowSize),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainColor.withAlpha(80),
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          left: 24, // Adjust arrow position
          child: CustomPaint(
            painter: ArrowPainter(color: backgroundColor),
            child: SizedBox(
              width: arrowSize,
              height: arrowSize,
            ),
          ),
        ),
      ],
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  ArrowPainter({
    required this.color,
    this.borderColor = AppColors.mainColor,
    this.borderWidth = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()..color = color;

    // Draw the arrow shape
    Path arrowPath = Path()
      ..moveTo(0, size.height) // Bottom left
      ..lineTo(size.width / 2, 0) // Top center
      ..lineTo(size.width, size.height) // Bottom right
      ..close();

    // Fill the arrow
    canvas.drawPath(arrowPath, fillPaint);

    // Paint for border on left and right sides
    Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw borders on the left and right sides only
    Path borderPath = Path()
      ..moveTo(0, size.height) // Bottom left
      ..lineTo(size.width / 2, 0) // Top center
      ..lineTo(size.width, size.height); // Bottom right

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
